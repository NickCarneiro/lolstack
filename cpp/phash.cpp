#include "/usr/include/mysql/mysql.h"
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <pHash.h>
#include <boost/lexical_cast.hpp>

//constants
#define MIN_HAM_DIST 12 //minimum hamming distance

using namespace std;
#if defined( _MSC_VER) || defined(_BORLANDC_)
typedef unsigned _uint64 ulong64;
typedef signed _int64 long64;
#else
typedef unsigned long long ulong64;
typedef signed long long long64;
#endif
int ph_dct_imagehash(const char *file, ulong64 &hash);
int ph_hamming_distance(ulong64 hasha, ulong64 hashb);
// just going to input the general details and not the port numbers
struct connection_details
{
    char *server;
    char *user;
    char *password;
    char *database;
};
 
MYSQL* mysql_connection_setup(struct connection_details mysql_details)
{
     // first of all create a mysql instance and initialize the variables within
    MYSQL *connection = mysql_init(NULL);
 
    // connect to the database with the details attached.
    if (!mysql_real_connect(connection,mysql_details.server, mysql_details.user, mysql_details.password, mysql_details.database, 0, NULL, 0)) {
      printf("Conection error : %s\n", mysql_error(connection));
      exit(1);
    }
    return connection;
}
 
MYSQL_RES* mysql_perform_query(MYSQL *connection, char *sql_query)
{
   // send the query to the database
   if (mysql_query(connection, sql_query))
   {
      printf("MySQL query error : %s\n", mysql_error(connection));
      exit(1);
   }
 
   return mysql_use_result(connection);
}
 
int main(int argc , char *argv[]){
  MYSQL *conn;		// the connection
  MYSQL_RES *res;	// the results
  MYSQL_ROW row;	// the results row (line by line)
 
  struct connection_details mysqlD;
  mysqlD.server = "localhost";  // where the mysql database is
  mysqlD.user = "root";		// the root user of mysql	
  mysqlD.password = "anonym00se"; // the password of the root user in mysql
  mysqlD.database = "lolstack";	// the databse to pick
 
 //arg 1= action: compare or gethash
	//arg 2= if compare: hash1, if gethash: image path
	//arg 3= if compare: hash2
	
	if (strcmp(argv[1],"gethash") == 0 ) {
		ulong64 hash1;
		ph_dct_imagehash(argv[2], hash1);	
		cout << hash1 << endl;
	}
	else if(strcmp(argv[1],"compare") == 0 ){
		ulong64 hash1 = boost::lexical_cast<ulong64>(argv[2]);
		ulong64 hash2 = boost::lexical_cast<ulong64>(argv[3]);
		int distance = ph_hamming_distance(hash1, hash2);
		cout << distance << endl;
	}
	else if(strcmp(argv[1],"checkhash") == 0 ){
		//query database for phash
		ulong64 hashToCheck = boost::lexical_cast<ulong64>(argv[2]);
		// connect to the mysql database
		conn = mysql_connection_setup(mysqlD);
	 
		// assign the results return to the MYSQL_RES pointer
		res = mysql_perform_query(conn, "SELECT phash,id FROM pics");
	 
		
		while ((row = mysql_fetch_row(res)) != NULL){
			//return pic id if hash within minimum distance
			// -1 if no matching pics found
			
			//printf("%s\n", row[0]);
		  	int distance = ph_hamming_distance(hashToCheck, boost::lexical_cast<ulong64>(row[0]));
			if(distance < MIN_HAM_DIST){
				//cout << "match within min_ham_dist: " << row[1] << endl;
				cout << boost::lexical_cast<int>(row[1]) << ":" << distance << ":"<<hashToCheck<<":"<<boost::lexical_cast<ulong64>(row[0]);
				return 1;
			}
			
		  }
		  //cout << "no matches found " << endl;
		  cout << -1;
		  return 0;
	 
		/* clean up the database result set */
		mysql_free_result(res);
		/* clean up the database link */
		mysql_close(conn);
	}
	else {
		cout << "Invalid number of arguments";
	}
  
 
  return 0;
}