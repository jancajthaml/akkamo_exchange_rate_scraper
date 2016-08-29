version := "1.0"

description := "Exchange Rate scraper"

scalaVersion in Global := "2.11.8"

lazy val numbers = RootProject(uri("git://github.com/jancajthaml/number.git#b417704bac0c4cbde505f9f560c50a54de407659"))
lazy val csv = RootProject(uri("git://github.com/jancajthaml/csv.git#cab2e180abc184e6c059ccbef9f82536b3caf6ed"))

lazy val root = (project in file(".")).settings(
  name := "exchange-scraper",
  mainClass in Compile := Some("eu.akkamo.Main"),
  libraryDependencies ++= Seq(
    "eu.akkamo" %% "akkamo" % "1.0.2"
  )
).dependsOn(numbers).dependsOn(csv).enablePlugins(AkkamoSbtPlugin)