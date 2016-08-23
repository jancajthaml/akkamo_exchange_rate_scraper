version := "1.0"

description := "Exchange Rate scraper"

scalaVersion in Global := "2.11.8"

lazy val root = (project in file(".")).settings(
  name := "exchange-scraper",
  mainClass in Compile := Some("eu.akkamo.Main"),
  libraryDependencies ++= Seq(
    "eu.akkamo" %% "akkamo" % "1.0.2"
  )
).enablePlugins(AkkamoSbtPlugin)