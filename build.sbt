version := "1.0"

description := "Exchange Rate scraper"

scalaVersion in Global := "2.11.8"

lazy val numbers = RootProject(uri("git://github.com/jancajthaml/number.git#b417704bac0c4cbde505f9f560c50a54de407659"))
lazy val csv = RootProject(uri("git://github.com/jancajthaml/csv.git#e75d5c8c4d1780f0b01743960b3f157a246aa3b8"))

lazy val root = (project in file(".")).settings(
  name := "exchange-scraper",
  mainClass in Compile := Some("eu.akkamo.Main"),
  libraryDependencies ++= Seq(
    "eu.akkamo" %% "akkamo" % "1.0.2"
  )
).dependsOn(numbers).dependsOn(csv).enablePlugins(AkkamoSbtPlugin)