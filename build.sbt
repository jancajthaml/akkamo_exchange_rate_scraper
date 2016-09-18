version := "1.0"

description := "Exchange Rate scraper"

scalaVersion in Global := "2.11.8"

lazy val csv = RootProject(uri("git://github.com/jancajthaml/csv.git#7c755b615036e070e601ead157e898707fa5be62"))

lazy val root = (project in file(".")).settings(
  name := "exchange-scraper",
  mainClass in Compile := Some("eu.akkamo.Main"),
  libraryDependencies ++= Seq(
    "eu.akkamo" %% "akkamo" % Versions.akkamo,
    "eu.akkamo" %% "akkamo-akka-http" % Versions.akkamo,
    "eu.akkamo" %% "akkamo-reactivemongo" % Versions.akkamo
  )
).dependsOn(csv).enablePlugins(AkkamoSbtPlugin)
