#!/usr/bin/env python

"""Tests for comicBookDB.py.
"""


__author__ = 'Jeff Cousens <jeffreyc@northwestern.edu>'
__version__ = '0.2'
__revision__ = '$LastChangedRevision$'
__date__ = '$LastChangedDate$'
__copyright__ = 'Copyright (c) 2007 Jeff Cousens'


import comicBookDB
import os
import unittest
from xml.dom.minidom import parseString


XMEN = """<Book>
  <field name="title">X-Men #100</field>
</Book>
"""

GROO = """<Book>
  <field name="title">Groo the Wanderer #3</field>
</Book>
"""

MAD = """<Book>
  <field name="title">MAD #177</field>
</Book>
"""


class TestComicBookDBUnits(unittest.TestCase):
    details = """<span class="page_headline"><a href="title.php?ID=593">X-Men (1991)</a> - #100</span><br><span class="page_subheadline">"End of Days"</span><br><a href="publisher.php?ID=4">Marvel Comics</a><br>

<table border="0" cellpadding="3" cellspacing="0">
  <tr>
    <td align="center" valign="top">
      <a href="graphics/comic_graphics/1/56/4223_20060327032452_large.jpg" target="_blank"><img src="graphics/comic_graphics/1/56/4223_20060327032452_thumb.jpg" alt="" width="100" border="1"></a><br>
      <a href="issue_image.php?ID=4223">Change this cover<br>or add a variant</a>

    </td>
    <td align="left" valign="top">&nbsp;</td>
    <td align="left" valign="top" width="366"><strong>Writer(s):</strong><br><a href="creator.php?ID=249">Chris Claremont</a><br><br><strong>Penciller(s):</strong><br><a href="creator.php?ID=1274">Leinil Francis Yu</a><br><br><strong>Inker(s):</strong><br><a href="creator.php?ID=494">Mark Morales</a><br><br><strong>Colorist(s):</strong><br><a href="creator.php?ID=1828">Liquid!</a><br><br><strong>Letterer(s):</strong><br><a href="creator.php?ID=342">Comicraft</a><br><a href="creator.php?ID=74">Richard Starkings</a><br><br><strong>Editor(s):</strong><br><a href="creator.php?ID=232">Robert Harras - 'Bob'</a><br><a href="creator.php?ID=90">Mark Powers</a><br><br><strong>Cover Artist(s):</strong><br><a href="creator.php?ID=407">Arthur Adams - 'Art'</a><br>    </td>

    <td align="left" valign="top">&nbsp;</td>
    <td align="right" valign="top" width="200" rowspan="2">
      <table border="0" cellpadding="0" cellspacing="0" width="100%"  class="noHeaderBox">
        <tr>
          <td align="center" valign="middle" width="100%">
            <br><span class="page_subheadline">Rating</span> <strong>(out of 10):</strong><br>
            <span class="rating">7.5</span><br>

            from <strong>2</strong> votes<br><br>You must be <a href="login.php">logged in</a> to vote!<br><br>          </td>
        </tr>
      </table><br>      
      <table border="0" cellpadding="0" cellspacing="0" width="100%" class="noHeaderBox">
        <tr>

          <td align="left" valign="middle" width="100%">
            <strong><u>Other members' collections</u></strong><br>
            &nbsp;&nbsp;This issue is in 97 collections.<br><br>&nbsp;&nbsp;<a href="market_issue.php?ID=4223">This issue is available for sale/trade</a><br>          </td>
        </tr>
      </table><br>      <table border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>

          <td align="left" valign="top" width="100%" class="listBox_header">
            Toolbox
          </td>
        </tr>
        <tr>
          <td align="left" valign="top" width="100%" class="bookBox">        <a href="issue_edit.php?ID=4223">Edit this Issue</a><br>
        <a href="issue_clone.php?ID=4223">Clone this Issue</a><br>            <a href="issue_history.php?ID=4223">View this issue's contribution history</a><br>

            <a href="problem_report.php?ID=4223&amp;type=Issue">Report a problem regarding this issue</a><br>
            <a href="creator_clone.php?ID=4223">Clone the creators of this issue</a><br>
            <a href="character_clone.php?ID=4223">Clone the characters of this issue</a><br>
          </td>
        </tr>
      </table>        <br><br>
        <div align="center"></div>

    </td>
  </tr>
  <tr>
    <td colspan="3">
      <br>        
        <a href="issue.php?ID=4221"><img src="graphics/button_prev.gif" alt="" width="56" height="17" border="0"></a> &nbsp;&nbsp;&nbsp; <a href="issue.php?ID=75577"><img src="graphics/button_next.gif" alt="" width="56" height="17" border="0"></a><br><br>      <strong>Cover Date:</strong> <a href="coverdate.php?month=5&amp;year=2000"> May 2000</a><br>

      <strong>Cover Price:</strong> US $2.99<br><br>"""
    nocover = """      <span class="page_headline"><a href="title.php?ID=14509">The Completely MAD Don Martin (1974)</a> - TPB</span><br><a href="publisher.php?ID=2677">E.C. Publications, Inc.</a><br>

<table border="0" cellpadding="3" cellspacing="0">
  <tr>
    <td align="center" valign="top">
      <img src="graphics/comic_graphics/nocover.gif" alt="" width="100" border="1"><br>
      <a href="issue_image.php?ID=99326">Change this cover<br>or add a variant</a>

    </td>
    <td align="left" valign="top">&nbsp;</td>
    <td align="left" valign="top" width="366"><strong>Writer(s):</strong><br><a href="creator.php?ID=2288">Don Martin</a><br><br><strong>Penciller(s):</strong><br><a href="creator.php?ID=2288">Don Martin</a><br><br><strong>Inker(s):</strong><br><a href="creator.php?ID=2288">Don Martin</a><br><br><strong>Colorist(s):</strong><br><a href="creator.php?ID=2554">(Story is monochromatic)</a><br><br><strong>Letterer(s):</strong><br><a href="creator.php?ID=1722">(Typeset)</a><br><br><strong>Editor(s):</strong><br><a href="creator.php?ID=11689">Jerry DeFuccio</a><br><a href="creator.php?ID=4130">Albert B. Feldstein</a><br><br><strong>Cover Artist(s):</strong><br><a href="creator.php?ID=2288">Don Martin</a><br>    </td>

    <td align="left" valign="top">&nbsp;</td>
    <td align="right" valign="top" width="200" rowspan="2">
      <table border="0" cellpadding="0" cellspacing="0" width="100%"  class="noHeaderBox">
        <tr>
          <td align="center" valign="middle" width="100%">
            <br><span class="page_subheadline">Rating</span> <strong>(out of 10):</strong><br>
            <span class="rating">Unrated</span><br>

            <br>You must be <a href="login.php">logged in</a> to vote!<br><br>          </td>
        </tr>
      </table><br>      
      <table border="0" cellpadding="0" cellspacing="0" width="100%" class="noHeaderBox">
        <tr>
          <td align="left" valign="middle" width="100%">
            <strong><u>Other members' collections</u></strong><br>

            &nbsp;&nbsp;This issue is in 1 collection.<br>          </td>
        </tr>
      </table><br>      <table border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
          <td align="left" valign="top" width="100%" class="listBox_header">
            Toolbox
          </td>
        </tr>

        <tr>
          <td align="left" valign="top" width="100%" class="bookBox">        <a href="issue_edit.php?ID=99326">Edit this Issue</a><br>
        <a href="issue_clone.php?ID=99326">Clone this Issue</a><br>            <a href="issue_history.php?ID=99326">View this issue's contribution history</a><br>
            <a href="problem_report.php?ID=99326&amp;type=Issue">Report a problem regarding this issue</a><br>
            <a href="creator_clone.php?ID=99326">Clone the creators of this issue</a><br>

            <a href="character_clone.php?ID=99326">Clone the characters of this issue</a><br>
          </td>
        </tr>
      </table>        <br><br>
        <div align="center"></div>
    </td>
  </tr>
  <tr>

    <td colspan="3">
      <br>        
              <strong>Cover Date:</strong> <a href="coverdate.php?month=18&amp;year=1974">  1974</a><br>
      <strong>Cover Price:</strong> US $4.95<br><br>"""
    editors = '<a href="creator.php?ID=232">Robert Harras - \'Bob\'</a><br><a href="creator.php?ID=90">Mark Powers</a>'

    def testDetailsExp(self):
        match = comicBookDB.DETAILS.search(self.details)
        assert match

    def testNoCoverExp(self):
        match = comicBookDB.DETAILS.search(self.nocover)
        assert match

    def testGetPeople(self):
        match = comicBookDB.PERSON.findall(self.editors)
        assert match


class TestComicBookDB(unittest.TestCase):

    def setUp(self):
        file = open('/tmp/books-quickfill.xml', 'w')
        file.write(XMEN)
        file.close()

    def tearDown(self):
        os.unlink('/tmp/books-quickfill.xml')

    def testLoadFile(self):
        result = comicBookDB.run()
        tree = parseString(result)
        fields = tree.getElementsByTagName('field')
        assert(fields[0].normalize().firstChild.data == 'X-Men #100')


if __name__ == '__main__':
    unittest.main()
