-- MySQL dump 10.11
--
-- Host: localhost    Database: alacast
-- ------------------------------------------------------
-- Server version	5.0.67

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `alacast`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `alacast` /*!40100 DEFAULT CHARACTER SET latin1 */;

USE `alacast`;

--
-- Table structure for table `broadcasts`
--

DROP TABLE IF EXISTS `broadcasts`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `broadcasts` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `podcast_id` int(10) unsigned NOT NULL,
  `URI` varchar(255) NOT NULL,
  `type` enum('www','m3u','pls','xspf','stream') NOT NULL default 'www',
  PRIMARY KEY  (`id`,`podcast_id`),
  KEY `podcast_constraint` (`podcast_id`),
  CONSTRAINT `podcast_constraint` FOREIGN KEY (`podcast_id`) REFERENCES `podcasts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `broadcasts`
--

LOCK TABLES `broadcasts` WRITE;
/*!40000 ALTER TABLE `broadcasts` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `broadcasts` VALUES (1,31,'http://www.ustream.tv/channel/tuesday-night-tech','www');
/*!40000 ALTER TABLE `broadcasts` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `feeds`
--

DROP TABLE IF EXISTS `feeds`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `feeds` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `website_id` int(10) unsigned NOT NULL,
  `title` varchar(40) default NULL,
  `URI` varchar(255) NOT NULL,
  `tags` varchar(255) default NULL,
  PRIMARY KEY  (`id`,`website_id`),
  KEY `website_id_contraint` (`website_id`),
  CONSTRAINT `website_id_contraint` FOREIGN KEY (`website_id`) REFERENCES `podcasts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `feeds`
--

LOCK TABLES `feeds` WRITE;
/*!40000 ALTER TABLE `feeds` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `feeds` VALUES (1,1,NULL,'http://www.astronomycast.com/podcast.xml',''),(2,2,NULL,'http://www.badscience.net/feed/',''),(3,3,'News and Features','http://www.dana.org/broadcasts/podcasts/feeds/podcasts_newsandfeatures.xml',''),(4,3,'Gray Matters','http://www.dana.org/broadcasts/podcasts/feeds/podcasts_gm.xml',''),(5,3,'Lectures','http://www.dana.org/broadcasts/podcasts/feeds/podcasts_lectures.xml',''),(6,3,'Panel Discussions','http://www.dana.org/broadcasts/podcasts/feeds/podcasts_panel.xml',''),(7,3,'One-on-One','http://www.dana.org/broadcasts/podcasts/feeds/podcasts_oneonone.xml',''),(8,4,'Extra','http://www.sciencefriday.com/feed/scifriextras.xml',''),(9,4,'Video','http://www.sciencefriday.com/video/scifrivideo.xml',''),(10,4,'Radio','http://www.npr.org/rss/podcast.php?id=510221',''),(11,5,NULL,'http://www.sciencemag.org/rss/podcast.xml ',NULL),(12,6,'Weekly','http://scienceupdate.com/podcastfeed.xml',NULL),(13,6,'Daily','http://scienceupdate.com/dailypodcastfeed.xml',NULL),(14,7,NULL,'http://leoville.tv/podcasts/itn.xml',NULL),(15,8,NULL,'http://leoville.tv/podcasts/twil.xml',NULL),(16,9,'ExtremeTech','http://feeds.ziffdavis.com/ziffdavis%2fextremetechpodcast?format=xml',NULL),(17,9,'CrankyGeeks','http://feeds.ziffdavis.com/ziffdavis%2fcgmpeg4video?format=xml',NULL),(18,9,'DL.TV','http://feeds.ziffdavis.com/ziffdavis%2fdltvdivxvideo?format=xml',NULL),(19,10,'CNet.TV from News.com','http://feeds.feedburner.com/cnet%2fnews?format=xml',NULL),(20,10,'The Buzz Report','http://feeds.feedburner.com/cnet%2fbuzzreport?format=xml',NULL),(21,10,'Loaded','http://feeds.feedburner.com/cnet%2floaded?format=xml',NULL),(22,10,'Inside CNet labs','http://feeds.feedburner.com/cnet%2finsidecnetlabs?format=xml',NULL),(23,10,'News.com','http://feeds.feedburner.com/cnet%2fnewsdaily?format=xml',NULL),(24,10,'Today in Tech History','http://feeds.feedburner.com/cnet%2ftechhistory?format=xml',NULL),(25,10,'the404','http://feeds.feedburner.com/The404?format=xml',NULL),(26,11,NULL,'http://www.discovery.com/radio/xml/news_video.xml',NULL),(27,12,'This Week @ NASA','http://www.nasa.gov/rss/TWAN_vodcast.rss',NULL),(28,12,'NASAcast','http://www.nasa.gov/rss/NASAcast_vodcast.rss',NULL),(29,13,NULL,'http://www.pgholyfield.com/maah/?feed=rss2','podnovel,mystery,fantasy'),(30,14,NULL,'http://globalgeek.thepodcastnetwork.com/feed/',NULL),(31,15,NULL,'http://feeds.pseudopod.org/Pseudopod?format=xml',NULL),(32,16,NULL,'http://feeds.feedburner.com/metamorcity?format=xml',NULL),(33,17,NULL,'http://feeds.alternageek.com/alternageek-ogg?format=xml',NULL),(34,18,NULL,'http://feeds.feedburner.com/cmdln?format=xml',NULL),(35,20,NULL,'http://www.thelinuxlink.net/tllts/tllts_ogg.rss',NULL),(36,19,NULL,'http://distrowatch.com/news/oggcast.xml',NULL),(37,21,NULL,'http://www.thesourceshow.org/theora.xml',NULL),(38,22,'Women In Technology (Audio)','http://www.informit.com/podcasts/index_rss.aspx?c=19',NULL),(39,23,NULL,'http://fanboyhell.libsyn.com/rss',NULL),(40,24,NULL,'http://recordings.talkshoe.com/rss20037.xml',NULL),(41,25,NULL,'http://www.blogtalkradio.com/GamerGirlsRadio/feed',NULL),(43,27,'video','http://www.democracynow.org/podcast-video.xml',NULL),(44,27,'audio','http://www.democracynow.org/podcast.xml',NULL),(45,29,'News from Archeologica','http://www.archaeologychannel.org/rss/TACfeed.xml',NULL),(46,30,'podcasts','http://feeds.feedburner.com/libsyn%2fNetSquared?format=xml',NULL),(47,30,'video','http://netsquared.blip.tv/?skin=rss',NULL),(48,31,NULL,'http://feeds.feedburner.com/tuesdaynighttech?format=xml',NULL),(49,32,NULL,'http://blog.stackoverflow.com/index.php?feed=podcast',NULL);
/*!40000 ALTER TABLE `feeds` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `podcasts`
--

DROP TABLE IF EXISTS `podcasts`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `podcasts` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `title` varchar(255) NOT NULL,
  `homepage` varchar(255) NOT NULL,
  `tags` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `podcasts`
--

LOCK TABLES `podcasts` WRITE;
/*!40000 ALTER TABLE `podcasts` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `podcasts` VALUES (1,'AstronomyCast','http://www.astronomycast.com/',NULL),(2,'BadScience','http://www.badscience.net/',NULL),(3,'Dana Foundation','http://www.dana.org/podcasts.aspx',NULL),(4,'NPR Science Fridays','http://www.sciencefriday.com/feeds/about/',NULL),(5,'Science Magazine Podcast','http://www.sciencemag.org/about/podcast.dtl',NULL),(6,'Science Update','http://www.scienceupdate.com/',NULL),(7,'net@night','http://www.twit.tv/natn','uberChicks,web2.0,online-culture'),(8,'this Week In Law','http://twit.tv/twil',NULL),(9,'ZiffDavis','http://www.extremetech.com/article2/0,1697,1857486,00.asp',NULL),(10,'C|Net\'s','http://podcast.cnet.com/',NULL),(11,'Discovery Video','http://dsc.discovery.com/news/rss.html',NULL),(12,'NASA','http://www.nasa.gov/multimedia/podcasting/index.html',NULL),(13,'Murder at Avedon Hill','http://www.pgholyfield.com/maah/',NULL),(14,'TheGlobalGeekPodcat','http://globalgeek.thepodcastnetwork.com/',NULL),(15,'Pseudopod','http://pseudopod.org/',NULL),(16,'MetamorCity','http://metamorcity.com/',NULL),(17,'Alternageek','http://alternageek.com/',NULL),(18,'TCLP','http://thecommandline.net/',NULL),(19,'Linux Link Tech Show','http://www.tllts.org/',NULL),(20,'DistroWatch','http://distrowatch.com/news/',NULL),(21,'the_source','http://www.thesourceshow.org/',NULL),(22,'informIT\'s','http://www.informit.com/podcasts/index.aspx?s=60185',NULL),(23,'Fan Boy Hell Radio','http://fanboyhell.libsyn.com/',NULL),(24,'The Linux Cranks','http://linuxcranks.info/',NULL),(25,'Gamer Girls Radio','http://www.GamerGirlsRadio.Com/',NULL),(27,'DemocracyNow','http://www.democracynow.org/',NULL),(28,'FSRN','http://fsrn.org/',NULL),(29,'Archeology Channel','http://www.archaeologychannel.org/',NULL),(30,'NetSquared','http://netsquared.org/',NULL),(31,'Tuesday Night Tech Show','http://tuesdaynighttech.blogspot.com/',NULL),(32,'Stack Over Flow','http://blog.stackoverflow.com/',NULL);
/*!40000 ALTER TABLE `podcasts` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping routines for database 'alacast'
--
DELIMITER ;;
DELIMITER ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2008-12-27  1:48:47
