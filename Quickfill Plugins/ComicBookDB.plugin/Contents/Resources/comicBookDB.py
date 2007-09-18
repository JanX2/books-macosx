#!/usr/bin/env python

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


title = ''
issue_number = ''
issue_id = 0


def add_field(doc, parent, name, value):
    field = doc.createElement('field')
    field.setAttribute('name', name)
    text = doc.createTextNode(value)
    field.appendChild(text)
    parent.appendChild(field)


def get_page(url):
    req = urllib2.Request(url)
    resp = urllib2.urlopen(req)
    return resp.read()


def get_people(text):
    people = ''
    matches = PERSON.findall(text)
    for match in matches:
        if match not in INVALID:
            people = '%s%s; ' % (people, match)
    return people.rstrip().rstrip(';')


def merge_people(plist):
    merged = ''
    for people in plist:
        merged = '%s%s; ' % (merged, people)
    return merged.rstrip().rstrip(';')


def print_output(matchdict=None):
    doc = Document()
    root = doc.createElement('importedData')
    doc.appendChild (root)

    if (matchdict):
        collection = doc.createElement('List')
        collection.setAttribute('name', 'ComicBookDB Import')
        root.appendChild(collection)

        book = doc.createElement('Book')
        book.setAttribute('title', title)

        add_field(doc, book, 'title', '%s #%s' % (title, issue_number))
        if matchdict['writer']:
            add_field(doc, book, 'authors', get_people(matchdict['writer']))
        if matchdict['penciller'] or matchdict['inker']:
            add_field(doc, book, 'illustrators',
                      merge_people([get_people(matchdict['penciller']),
                                   get_people(matchdict['inker'])]))
        if matchdict['editor']:
            add_field(doc, book, 'editor', get_people(matchdict['editor']))
        if matchdict['publisher']:
            add_field(doc, book, 'publisher', matchdict['publisher'])
        if matchdict['year'] and matchdict['month']:
            add_field(doc, book, 'publishDate',
                      '%s 1, %s' % (matchdict['month'], matchdict['year']))
        elif matchdict['year']:
            add_field(doc, book, 'publishDate', 'January 1, %s' % matchdict['year'])
        if matchdict['cover']:
            add_field(doc, book, 'CoverImageURL',
                      'http://www.comicbookdb.com/%s' % matchdict['cover'])
        add_field(doc, book, 'link',
                  'http://www.comicbookdb.com/issue.php?ID=%s' % issue_id)

        collection.appendChild(book)

    print doc.toprettyxml(encoding='UTF-8', indent='  ')

    sys.stdout.flush()


def run():
    global title, issue_number, issue_id
    title_id = 0
    issue_id = 0

    # <Book>
    #   <field name="listName">My Books</field>
    #   <field name="publisher">This is the publisher</field>
    #   <field name="publishDate">1984-09-16</field>
    #   <field name="translators">This is the translator</field>
    #   <field name="illustrators">This is the ill ustrator</field>
    #   <field name="isbn">1234567890</field>
    #   <field name="editors">This is the editor</field>
    #   <field name="id">0A9EB127-B801-4B86-83D0-5DB895E2B4BF</field>
    #   <field name="series">This is the series</field>
    #   <field name="authors">This is the author</field>
    #   <field name="title">This is the title</field>
    #   <field name="summary">Summary goes here</field>
    #   <field name="genre">This is the genre</field>
    # </Book>
    tree = parse('/tmp/books-quickfill.xml')
    fields = tree.getElementsByTagName('field')

    for field in fields:
        field.normalize()

        if field.firstChild != None:
            data = field.firstChild.data.replace(
                    '&', '').replace('(', '').replace(')', '')
            if field.getAttribute('name') == 'title':
                (title, issue_number) = data.split('#')
                title = title.rstrip()
            # elif field.getAttribute('name') == 'publisher':
            #     publisher = data
            # elif field.getAttribute('name') == 'publishDate':
            #     (year, month, day) = data.split('-')

    title_list = get_page('http://www.comicbookdb.com/search.php?'
            'form_search=%s&form_searchtype=Title' % urllib.quote(title))

    matches = TITLE.findall(title_list)

    for match in matches:
        # match looks like ('title_id', 'title', 'year', 'publisher')
        t = unicode(match[1], 'iso-8859-1')
        if t == title:
            title_id = match[0]
            break

    if not title_id:
        print_output()
    else:

        issue_list = get_page(
                'http://www.comicbookdb.com/title.php?ID=%s' % title_id)

        matches = ISSUE.findall(issue_list)

        for match in matches:
            # match looks like ('issue_id', 'issue_number')
            if match[1] == issue_number:
                issue_id = match[0]
                break

        if not issue_id:
            print_output()
        else:

            issue_details = get_page(
                    'http://www.comicbookdb.com/issue.php?ID=%s' % issue_id)
            match = DETAILS.search(issue_details)

            print_output(match.groupdict())


if __name__ == '__main__':
    run()
