#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""A custom importer for Books that scrapes ComicBookDB
<http://www.comicbookdb.com/> to download and quickfill comic book data.
"""


__author__ = 'Jeff Cousens <jeffreyc@northwestern.edu>'
__version__ = '0.2'
__revision__ = '$LastChangedRevision$'
__date__ = '$LastChangedDate$'
__copyright__ = 'Copyright (c) 2007 Jeff Cousens'


import re
import sys
import urllib
import urllib2
from xml.dom.minidom import Document, parse


INVALID = ['(Story is monochromatic)', '(Typeset)']


TITLE = re.compile(
        '<a href="title.php\?ID=(\d+)">([^(]+) \((\d+)\)</a> \(([^)]+)\)')
ISSUE = re.compile('<a href="issue.php\?ID=(\d+)">(\d+)</a><br>')
PUBLISHER = re.compile(
    '<a\ href="publisher.php\?ID=\d+">(?P<publisher>[^<]*)</a><br>')
IMAGES = re.compile(
    '<a\ href="(?P<cover>[^"]+)"\ target="_blank"><img\ src="(?P<thumb>[^"]+)"\ alt=""\ width="100"\ border="1"></a><br>')
ROLES = re.compile(
    '<strong>(?P<role>[^<]+)\(s\):</strong><br>(?P<value>.*?)(?:<br><br>|<br>\ \ \ \ </td>)')
PUBDATE = re.compile(
    '<a\ href="coverdate.php\?month=\d+&amp;year=\d+">\ (?P<month>\w*)\ (?P<year>\d*)</a>')
DETAILS = re.compile("""
    <a\ href="publisher.php\?ID=\d+">(?P<publisher>[^<]*)</a><br>.*
    (?:<a\ href="(?P<cover>[^"]+)"\ target="_blank">
       <img\ src="(?P<thumb>[^"]+)"\ alt=""\ width="100"\ border="1"></a><br> |
       <img\ src="graphics/comic_graphics/nocover.gif"\ alt=""\ width="100"\ border="1"><br>).*
    <strong>Writer\(s\):</strong><br>(?P<writer>.*)<br><br>
    <strong>Penciller\(s\):</strong><br>(?P<penciller>.*)<br><br>
    <strong>Inker\(s\):</strong><br>(?P<inker>.*)<br><br>
    <strong>Colorist\(s\):</strong><br>(?P<colorist>.*)<br><br>
    <strong>Letterer\(s\):</strong><br>(?P<letterer>.*)<br><br>
    <strong>Editor\(s\):</strong><br>(?P<editor>.*)<br><br>
    <strong>Cover\ Artist\(s\):</strong><br>(?P<artist>.*)<br>\ \ \ \ </td>.*
    <a\ href="coverdate.php\?month=\d+&amp;year=\d+">
    \ (?P<month>\w*)\ (?P<year>\d*)</a>""",
    re.DOTALL | re.VERBOSE)
PERSON = re.compile('<a href="\w+.php\?ID=\d+">([^<]+)</a>')


def add_field(doc, parent, name, value):
    field = doc.createElement('field')
    field.setAttribute('name', name)
    text = doc.createTextNode(value.decode('iso-8859-1'))
    field.appendChild(text)
    parent.appendChild(field)


def get_issue_details(title_id, issue_number):
    """Searches the text of an issue's details to find the values to quickfill.

    Returns a Match Object.

        >>> match = get_issue_details(593, '100')
        >>> match['publisher']
        'Marvel Comics'
        >>> match['cover']
        'graphics/comic_graphics/1/56/4223_20060327032452_large.jpg'
        >>> match['thumb']
        'graphics/comic_graphics/1/56/4223_20060327032452_thumb.jpg'
        >>> match['writer']
        '<a href="creator.php?ID=249">Chris Claremont</a>'
        >>> match['penciller']
        '<a href="creator.php?ID=1274">Leinil Francis Yu</a>'
        >>> match['inker']
        '<a href="creator.php?ID=494">Mark Morales</a>'
        >>> match['colorist']
        '<a href="creator.php?ID=1828">Liquid!</a>'
        >>> match['letterer']
        '<a href="creator.php?ID=342">Comicraft</a><br><a href="creator.php?ID=74">Richard Starkings</a>'
        >>> match['editor']
        '<a href="creator.php?ID=232">Robert Harras - \\'Bob\\'</a><br><a href="creator.php?ID=90">Mark Powers</a>'
        >>> match['artist']
        '<a href="creator.php?ID=407">Arthur Adams - \\'Art\\'</a>'
        >>> match['year']
        '2000'
        >>> match['month']
        'May'
        >>> match = get_issue_details(84, '3')
        >>> match['artist']
        '<a href="creator.php?ID=212">Sergio Aragon\\xe9s</a>'
        >>> 
    """
    issue_id = get_issue_id(title_id, issue_number)

    if not issue_id:
        return {'issue_id': '0'}

    issue_details = get_page(
            'http://www.comicbookdb.com/issue.php?ID=%s' % issue_id)
    
    match = {'issue_id': issue_id}
    mo = PUBLISHER.search(issue_details)
    if mo:
        mod = mo.groupdict()
        match['publisher'] = mod['publisher']
    mo = IMAGES.search(issue_details)
    if mo:
        mod = mo.groupdict()
        match['cover'] = mod['cover']
        match['thumb'] = mod['thumb']
    matches = ROLES.findall(issue_details)
    for m in matches:
        # match looks like ('role', 'value')
        if m[0] == 'Cover Artist':
            match['artist'] = m[1]
        else:
            match[m[0].lower()] = m[1]
    mo = PUBDATE.search(issue_details)
    if mo:
        mod = mo.groupdict()
        match['month'] = mod['month']
        match['year'] = mod['year']

    return match


def get_issue_id(title_id, issue_number):
    """Searches the list of issues for a title to find an issue's id.
        >>> get_issue_id(84, '3')
        '15903'
        >>> get_issue_id(593, '100')
        '4223'
        >>> 
    """
    issue_id = 0

    issue_list = get_page(
            'http://www.comicbookdb.com/title.php?ID=%s' % title_id)

    matches = ISSUE.findall(issue_list)

    for match in matches:
        # match looks like ('issue_id', 'issue_number')
        if match[1] == issue_number:
            issue_id = match[0]
            break

    return issue_id

def get_page(url):
    req = urllib2.Request(url)
    resp = urllib2.urlopen(req)
    return resp.read()


def get_people(text):
    """Searches the text contained in a role block to extract the people and
    build a semi-colon separated list of names.

    get_people should be called with the groupdict values obtained by matching
    the issue page against the DETAILS regexp.

        >>> writer = '<a href="creator.php?ID=249">Chris Claremont</a>'
        >>> penciller = '<a href="creator.php?ID=1274">Leinil Francis Yu</a>'
        >>> letterer = '<a href="creator.php?ID=342">Comicraft</a><br><a href="creator.php?ID=74">Richard Starkings</a>'
        >>> editor = '<a href="creator.php?ID=232">Robert Harras - \\'Bob\\'</a><br><a href="creator.php?ID=90">Mark Powers</a>'
        >>> get_people(writer)
        'Chris Claremont'
        >>> get_people(penciller)
        'Leinil Francis Yu'
        >>> get_people(letterer)
        'Comicraft; Richard Starkings'
        >>> get_people(editor)
        "Robert Harras - 'Bob'; Mark Powers"
        >>> 
    """
    people = ''
    matches = PERSON.findall(text)
    for match in matches:
        if match not in INVALID:
            people = '%s%s; ' % (people, match)
    return people.rstrip().rstrip(';')


def merge_people(plist):
    """Merges the results of get_people into a single list.

    This is needed for fields where multiple ComicBookDB fields relate to a
    single Books field.

    merge_people should be called with a list containing the return value of
    get_people.

        >>> writer = '<a href="creator.php?ID=249">Chris Claremont</a>'
        >>> penciller = '<a href="creator.php?ID=1274">Leinil Francis Yu</a>'
        >>> inker = '<a href="creator.php?ID=494">Mark Morales</a>'
        >>> letterer = '<a href="creator.php?ID=342">Comicraft</a><br><a href="creator.php?ID=74">Richard Starkings</a>'
        >>> editor = '<a href="creator.php?ID=232">Robert Harras - \\'Bob\\'</a><br><a href="creator.php?ID=90">Mark Powers</a>'
        >>> merge_people([get_people(writer)])
        'Chris Claremont'
        >>> merge_people([get_people(penciller), get_people(inker)])
        'Leinil Francis Yu; Mark Morales'
        >>> merge_people([get_people(writer), get_people(penciller),
        ...               get_people(inker)])
        'Chris Claremont; Leinil Francis Yu; Mark Morales'
        >>> merge_people([get_people(letterer), get_people(editor)])
        "Comicraft; Richard Starkings; Robert Harras - 'Bob'; Mark Powers"
        >>> 
    """
    merged = ''
    for people in plist:
        merged = '%s%s; ' % (merged, people)
    return merged.rstrip().rstrip(';')


def parse_books_quickfill():
    """Parses the books-quickfill XML file to read values about the book to
    find.

    The title will be split on the octothorp (#) to find the title and issue
    number; e.g., "X-Men #100" will be split into a title of "X-Men" and an
    issue number of 100. A sample books-quickfill.xml file is:

        <Book>
          <field name="listName">My Books</field>
          <field name="publisher">This is the publisher</field>
          <field name="publishDate">1984-09-16</field>
          <field name="translators">This is the translator</field>
          <field name="illustrators">This is the ill ustrator</field>
          <field name="isbn">1234567890</field>
          <field name="editors">This is the editor</field>
          <field name="id">0A9EB127-B801-4B86-83D0-5DB895E2B4BF</field>
          <field name="series">This is the series</field>
          <field name="authors">This is the author</field>
          <field name="title">This is the title</field>
          <field name="summary">Summary goes here</field>
          <field name="genre">This is the genre</field>
        </Book>

    Currently this only searches for title and publisher.

        >>> MAD = '''<Book>
        ...   <field name="title">MAD #177</field>
        ... </Book>'''
        >>> GROO = '''<Book>
        ...   <field name="title">Groo the Wanderer #3</field>
        ...   <field name="publisher">Pacific Comics</field>
        ... </Book>'''
        >>> XMEN = '''<Book>
        ...   <field name="title">X-Men #100</field>
        ...   <field name="publisher">Marvel Comics</field>
        ... </Book>'''
        >>> file = open('/tmp/books-quickfill.xml', 'w')
        >>> file.write(MAD)
        >>> file.close()
        >>> parse_books_quickfill()
        ('MAD', '177', '')
        >>> file = open('/tmp/books-quickfill.xml', 'w')
        >>> file.write(GROO)
        >>> file.close()
        >>> parse_books_quickfill()
        ('Groo the Wanderer', '3', 'Pacific Comics')
        >>> file = open('/tmp/books-quickfill.xml', 'w')
        >>> file.write(XMEN)
        >>> file.close()
        >>> parse_books_quickfill()
        ('X-Men', '100', 'Marvel Comics')
        >>> import os
        >>> os.unlink('/tmp/books-quickfill.xml')
        >>> 
    """
    title = ''
    issue_number = ''
    publisher = ''

    tree = parse('/tmp/books-quickfill.xml')
    fields = tree.getElementsByTagName('field')

    for field in fields:
        field.normalize()

        if field.firstChild != None:
            data = str(field.firstChild.data.replace(
                    '&', '').replace('(', '').replace(')', ''))
            if field.getAttribute('name') == 'title':
                (title, issue_number) = data.split('#')
                title = title.rstrip()
            elif field.getAttribute('name') == 'publisher':
                publisher = data
            # elif field.getAttribute('name') == 'publishDate':
            #     (year, month, day) = data.split('-')
    return (title, issue_number, publisher)


def print_output(title='', title_ids=[], issue_number=''):
    doc = Document()
    root = doc.createElement('importedData')
    doc.appendChild (root)

    if (title_ids):
        collection = doc.createElement('List')
        collection.setAttribute('name', 'ComicBookDB Import')
        root.appendChild(collection)

        for title_id in title_ids:

            match = get_issue_details(title_id, issue_number)

            book = doc.createElement('Book')
            book.setAttribute('title', title)

            add_field(doc, book, 'title', '%s #%s' % (title, issue_number))
            if match.has_key('writer') and match['writer']:
                add_field(doc, book, 'authors', get_people(match['writer']))
            if (match.has_key('penciller') and match['penciller'] and
                match.has_key('inker') and match['inker']):
                add_field(doc, book, 'illustrators',
                          merge_people([get_people(match['penciller']),
                                        get_people(match['inker'])]))
            elif match.has_key('penciller') and match['penciller']:
                add_field(doc, book, 'illustrators',
                          get_people(match['penciller']))
            elif match.has_key('inker') and match['inker']:
                add_field(doc, book, 'illustrators', get_people(match['inker']))
            if match.has_key('editor') and match['editor']:
                add_field(doc, book, 'editor', get_people(match['editor']))
            if match.has_key('publisher') and match['publisher']:
                add_field(doc, book, 'publisher', match['publisher'])
            if (match.has_key('year') and match['year'] and
                match.has_key('month') and match['month']):
                add_field(doc, book, 'publishDate',
                          '%s 1, %s' % (match['month'], match['year']))
            elif match.has_key('year') and match['year']:
                add_field(doc, book, 'publishDate', 'January 1, %s' % match['year'])
            if match.has_key('cover') and match['cover']:
                add_field(doc, book, 'CoverImageURL',
                          'http://www.comicbookdb.com/%s' % match['cover'])
            add_field(doc, book, 'link',
                      'http://www.comicbookdb.com/issue.php?ID=%s' % (
                      match['issue_id']))

            collection.appendChild(book)

    print doc.toprettyxml(encoding='UTF-8', indent='  ').rstrip()

    sys.stdout.flush()


def query():
    """Queries ComicBookDB to get issue details.

        >>> GROO = '''<Book>
        ...   <field name="title">Groo the Wanderer #3</field>
        ...   <field name="publisher">Pacific Comics</field>
        ... </Book>'''
        >>> XMEN = '''<Book>
        ...   <field name="title">X-Men #100</field>
        ...   <field name="publisher">Marvel Comics</field>
        ... </Book>'''
        >>> file = open('/tmp/books-quickfill.xml', 'w')
        >>> file.write(GROO)
        >>> file.close()
        >>> query()
        <?xml version="1.0" encoding="UTF-8"?>
        <importedData>
          <List name="ComicBookDB Import">
            <Book title="Groo the Wanderer">
              <field name="title">
                Groo the Wanderer #3
              </field>
              <field name="publisher">
                Pacific Comics
              </field>
              <field name="publishDate">
                April 1, 1983
              </field>
              <field name="CoverImageURL">
                http://www.comicbookdb.com/graphics/comic_graphics/1/24/15903_20051209094425_large.jpg
              </field>
              <field name="link">
                http://www.comicbookdb.com/issue.php?ID=15903
              </field>
            </Book>
            <Book title="Groo the Wanderer">
              <field name="title">
                Groo the Wanderer #3
              </field>
              <field name="authors">
                Mark Evanier
              </field>
              <field name="illustrators">
                Sergio Aragonés; Sergio Aragonés
              </field>
              <field name="publishDate">
                May 1, 1985
              </field>
              <field name="CoverImageURL">
                http://www.comicbookdb.com/graphics/comic_graphics/1/4/287_20050924142121_large.jpg
              </field>
              <field name="link">
                http://www.comicbookdb.com/issue.php?ID=287
              </field>
            </Book>
          </List>
        </importedData>
        >>> file = open('/tmp/books-quickfill.xml', 'w')
        >>> file.write(XMEN)
        >>> file.close()
        >>> query()
        <?xml version="1.0" encoding="UTF-8"?>
        <importedData>
          <List name="ComicBookDB Import">
            <Book title="X-Men">
              <field name="title">
                X-Men #100
              </field>
              <field name="authors">
                Chris Claremont
              </field>
              <field name="illustrators">
                Leinil Francis Yu; Mark Morales
              </field>
              <field name="editor">
                Robert Harras - 'Bob'; Mark Powers
              </field>
              <field name="publisher">
                Marvel Comics
              </field>
              <field name="publishDate">
                May 1, 2000
              </field>
              <field name="CoverImageURL">
                http://www.comicbookdb.com/graphics/comic_graphics/1/56/4223_20060327032452_large.jpg
              </field>
              <field name="link">
                http://www.comicbookdb.com/issue.php?ID=4223
              </field>
            </Book>
          </List>
        </importedData>
        >>> 
    """
    title_ids = []

    (title, issue_number, publisher) = parse_books_quickfill()

    title_list = get_page('http://www.comicbookdb.com/search.php?'
            'form_search=%s&form_searchtype=Title' % urllib.quote(title))

    matches = TITLE.findall(title_list)

    for match in matches:
        # match looks like ('title_id', 'title', 'year', 'publisher')
        if match[1] == title:
            title_ids.append(match[0])

    if not title_ids:
        print_output()
    else:
        print_output(title, title_ids, issue_number)


def test():
    import doctest
    doctest.testmod()


if __name__ == '__main__':
    query()
    #test()
