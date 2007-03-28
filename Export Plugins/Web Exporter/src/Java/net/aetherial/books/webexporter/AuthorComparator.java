package net.aetherial.books.webexporter;

import java.util.*;

public class AuthorComparator implements Comparator
{
	public String getCompareString (String original)
	{
		String newString = "" + original;
		
		String[] seperators = {";", ",", "/"};

		for (int i = 0; i < seperators.length; i++)
		{
			String seperator = seperators[i];

			int index = newString.indexOf (seperator);
			
			if (index != -1)
				newString = newString.substring(0, index);
		}

		int index = newString.lastIndexOf (" ");
		
		if (index != -1)
			newString = newString.substring (index + 1);

		return newString;
	}

	public int compare (Object one, Object two) 
	{
		return this.getCompareString (one.toString ()).compareToIgnoreCase (this.getCompareString (two.toString ()));
	}
}
