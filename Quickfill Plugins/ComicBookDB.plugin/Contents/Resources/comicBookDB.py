#!/usr/bin/env python

"""A custom importer for Books that scrapes ComicBookDB
<http://www.comicbookdb.com/> to download and quickfill cover art.
"""


__author__ = "Jeff Cousens <jeffreyc@northwestern.edu>"
__version__ = "0.1"


import re
import sys
import urllib
import urllib2
from xml.dom.minidom import Document, parse


TITLE = re.compile(
        '<a href="title.php\?ID=(\d+)">([^(]+) \((\d+)\)</a> \(([^)]+)\)')
ISSUE = re.compile('<a href="issue.php\?ID=(\d+)">(\d+)</a><br>')
COVER = re.compile('<a href="(graphics/comic_graphics/[^"]+.jpg)" target="_blank"><img src="graphics/comic_graphics/[^"]+_thumb.jpg" alt="" width="100" border="1"></a><br>')


def fuzzy_match(one, two):
    if one == two or one.find(two) >= 0 or two.find(one) >= 0:
        return True
    return False


def get_page(url):
    req = urllib2.Request(url)
    resp = urllib2.urlopen(req)
    return resp.read()


def print_output(image_path=None):
    doc = Document()
    root = doc.createElement('importedData')
    doc.appendChild (root)

    if (image_path): 
        collection = doc.createElement('List')
        collection.setAttribute('name', 'ComicBookDB Import')
        root.appendChild(collection)

        bookElement = doc.createElement('Book')
        bookElement.setAttribute('title', title)

        fieldElement = doc.createElement('field')
        fieldElement.setAttribute('name', 'CoverImageURL')

        textElement = doc.createTextNode(
                'http://www.comicbookdb.com/%s' % image_path)

        fieldElement.appendChild(textElement)
        bookElement.appendChild(fieldElement)

        collection.appendChild(bookElement)

    print doc.toprettyxml(encoding='UTF-8', indent=' ')

    sys.stdout.flush()

    sys.exit()


title = ''
issue_number = ''
publisher = ''
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
dom = parse('/tmp/books-quickfill.xml')
fields = dom.getElementsByTagName ('field')

for field in fields:
    field.normalize()

    if field.firstChild != None:
        data = field.firstChild.data.replace(
                '&', '').replace('(', '').replace(')', '')
        if field.getAttribute('name') == 'title':
            (title, issue_number) = data.split('#')
            title = title.rstrip()
        elif field.getAttribute('name') == 'publisher':
            publisher = data
        # elif field.getAttribute('name') == 'publishDate':
        #     (year, month, day) = data.split('-')

title_list = get_page(
        'http://www.comicbookdb.com/search.php?form_search=%s&form_searchtype=Title' % (
        urllib.quote(title)))

matches = TITLE.findall(title_list)

for match in matches:
    # match looks like ('title_id', 'title', 'year', 'publisher')
    if match[1] == title and fuzzy_match(match[3], publisher):
        title_id = match[0]
        break

if not title_id:
    print_output()

issue_list = get_page('http://www.comicbookdb.com/title.php?ID=%s' % title_id)

matches = ISSUE.findall(issue_list)

for match in matches:
    # match looks like ('issue_id', 'issue_number')
    if match[1] == issue_number:
        issue_id = match[0]
        break

if not issue_id:
    print_output()

issue_details = get_page('http://www.comicbookdb.com/issue.php?ID=%s' % issue_id)
print issue_id
match = COVER.search(issue_details)

print_output(match.groups()[0])
