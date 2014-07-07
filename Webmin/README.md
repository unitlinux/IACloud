Make bacula module working with upercase characters

To avoid the "Missing or invalid * name" error need to make some changes.

Go to directory:
/usr/share/webmin/bacula-backup

In section

# Validate and store inputs
$in{'name'} =~ /^[a-z0-9\.\-\_]+$/
Change "a-z0-9" to "A-Za-z0-9"

in files:
save_director.cgi
save_file.cgi
save_storagec.cgi
