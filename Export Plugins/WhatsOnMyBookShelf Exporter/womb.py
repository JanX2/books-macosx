#!/usr/bin/python

import sys
from SOAPpy import SOAPProxy

user = sys.argv[1]
password = sys.argv[2]
tags = sys.argv[3]
comment = sys.argv[4]

if (comment == None or comment == ""):
	comment = "Uploaded by Books. (http://books.aetherial.net/)"
 
url = 'http://whatsonmybookshelf.com/api/index.php'
namespace = 'urn:womb'  
server = SOAPProxy(url, namespace)      
server.encoding = 'US-ASCII'
auth_result = server.authUser(user, password)

if (auth_result.sessionID == ""):
	sys.exit (-1)
	
file = open("/tmp/books-export/womb.txt")

error_string = ""

for line in file.readlines():
	if (line != ""):
		isbn = line.split (" ")[0].strip ()

		print (isbn)

		result = server.registerBookByISBN (auth_result['sessionID'], isbn, tags, comment)

		if (result.errorText != ""):
			error_string = error_string + isbn + ": " + result.errorText + "\n"

f = open ("/tmp/books-export/womb.error", "w")
f.write (error_string)
f.close ()

sys.exit (0)
