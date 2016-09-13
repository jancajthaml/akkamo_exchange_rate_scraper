version := "1.0"

description := "Exchange Rate scraper"

scalaVersion in Global := "2.11.8"

lazy val numbers = RootProject(uri("git://github.com/jancajthaml/number.git#b417704bac0c4cbde505f9f560c50a54de407659"))
lazy val csv = RootProject(uri("git://github.com/jancajthaml/csv.git#841abb70a5c0b64c1e17a49f54cae469a260e4b1"))

lazy val root = (project in file(".")).settings(
  name := "exchange-scraper",
  mainClass in Compile := Some("eu.akkamo.Main"),
  libraryDependencies ++= Seq(
    "eu.akkamo" %% "akkamo" % Versions.akkamo,
    "eu.akkamo" %% "akkamo-akka-http" % Versions.akkamo,
    "eu.akkamo" %% "akkamo-reactivemongo" % Versions.akkamo
  )
).dependsOn(numbers).dependsOn(csv).enablePlugins(AkkamoSbtPlugin)
