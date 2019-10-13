# laughing-carnival

Project Summary
The purpose of this database is to track a breeding program at a local aviary. Breeding pairs must be tracked to ensure the health and genetic diversity of offspring and future generations. The importance of this tracking is far-reaching, as it not only benefits the birds staying at the aviary, but also benefits partnering zoos who may purchase birds for cost, and some birds may be released into the wild to help struggling populations. Birds at this aviary may be from partnering zoos, born in-house, or captured from the wild. The information gained from this database benefits veterinary care (offering family history), and observational data used for research about local versus wild populations.

Stakeholder Description
Stakeholders include:
Zookeepers, origin zoo (aviary)
Veterinarians
Zookeepers, partner zoo
Researchers
Other aviary and animal care staff (avoid inbreeding, do not house certain pairs together for enclosure cleaning, etc.)

Data Questions
Who are the top 3 most/least prolific breeding pairs?
 
Who are the top 3 most/least prolific male/female of the breeding pairs?
 
What is the average number of offspring by zoo?
 
What is the average number of male/female offspring per zoo?
 
How much revenue has the producing facility earned (this year) through the breeding program?


Glossary

AcctBalance Account balance of individual zoos.

BandID Primary Key, identification attribute of Bird entity.

BandID_F Female bird of mating pair.

BandID_M Male bird of mating pair.

Bird Entity containing all birds in the program.

Birthdate Attribute of Bird entity, not required if bird was obtained from the wild.

BuyingZooID Identification attribute of Transaction entity, zoo purchasing birds.

EstAge Attribute of Bird entity. Estimated Age is important for breeding age. Birthdates are not available if bird was obtained from the wild, so estimated age is required for all birds.

Gender Required attribute of Bird entity, male or female.

Mating_Pair Entity, details about mating pairs.

MatingPairID Composite Primary Key containing two band_ids (male and female), identification attribute of Mating Pair entity; Foreign key attribute of Bird entity. Some birds are obtained from the wild, so mating_pair_id is not required.

Price Attribute of various entities, detailing cost or account balance.

SellingZooID Identification attribute of Transaction entity, zoo selling birds.

Transaction Entity, transaction details.

TransactionID Primary Key, identification attribute of Transaction entity.

Wild Entity, birds can be obtained from, or released to locations in the wild.

WildDesc Text string name of a wild location.

WildID Primary Key of Wild entity. Indicates current location of bird if filled.

Zoo Entity, participates in transactions, houses birds.

ZooID Primary Key, identification attribute of Zoo entity. Indicates current location of bird if filled.

ZooName Text string name of a Zoo.

REFLECTION - 

How did your assumptions from the start of the project change? 
What would you do differently?
My assumptions at the start of the project were that this would be a fully functioning and interactive database, ready to deploy. Detailed further in the next section, I spent a lot of time trying to craft relationships for the input between tables, and even imagined a IF/THEN, to prevent inbreeding. I also found that in constructing the repeatable script, and later while creating the statements to answer the data questions - that some of the FKs and CONSTRAINTS need to be updated or omitted entirely, as some were found to be unnecessary. Truly, my learning evolved throughout this construction.

Based on what I have learned, some things I would do differently are:
Budget my time differently. As mentioned above, I spent the bulk of the time allotted trying to dream up some very complicated procedures, and learned later that it was okay to put in ‘placeholder’ data for the purposes of demonstration. I now see these ideas as opportunities for expansion, like creating a Breeding procedure, that generates a number of chicks and their attributes, placing them into the Bird table. I was able to do this successfully with the Transaction procedure. What I learned from this is that it may be best to put in the ‘placeholder’ data even if you will ultimately craft a procedure such as Breeding, so that you can pinpoint any errors in the interaction of these fields as you craft each statement. Later versions of this database would also eliminate the need for BandID_M and BandID_F as the Breeding procedure would check the intakes for the Gender attribute.

Other hiccups include the report for Data Question 2. I was able to generate an image using the ‘Blank Report’ template, but when trying to convert it to other views, it generated an endless loop of ODBC connections, sometimes crashing Access. My guess is that it was connecting for each instance of ‘chick’ for both male and female tables, which in this case would be 64 times. I used passthrough queries for each table, and perhaps there is another solution that could alleviate this issue.

Question 3 could have been answered more intuitively with a bit of database redesign, by including attribute ‘Birthplace’ or ‘Origin’ for each Bird.

Updates to Conceptual and Logical Models
Updated Conceptual and Logical Models to reflect updates to decimals; updates to MatingPairID, removed some unnecessary UNIQUE CONSTRAINTS; as well updating columns as named in the SQL script.

Updates to Glossary
Updated Glossary to match naming conventions used in the SQL script. Adding definitions for BandID_M, BandID_F.

Updates to Data Questions
Changed Question 3 from ‘Average number of offspring per nest?’ to ‘Average number of offspring per zoo?’ because the original was too similar to Question 1. The revision is helpful information for the respective zoos.
Changed Question 4 from ‘Average number of male to female offspring per nest?’ to ‘Average number of male to female offspring per zoo?’ because the original was proving difficult to code with the existing database design. The revision provides helpful information for the respective zoos, similar to Revised Question 3.
