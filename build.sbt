version := "1.0"

description := "Exchange Rate scraper"

scalaVersion in Global := "2.11.8"

//lazy val numbers = RootProject(uri("git://github.com/jancajthaml/number.git#b417704bac0c4cbde505f9f560c50a54de407659"))
lazy val csv = RootProject(uri("git://github.com/jancajthaml/csv.git#01aafcea8ad7aa5d8515f5aadbd2e15c16f8ffae"))

lazy val root = (project in file(".")).settings(
  name := "exchange-scraper",
  mainClass in Compile := Some("eu.akkamo.Main"),
  libraryDependencies ++= Seq(
    "eu.akkamo" %% "akkamo" % Versions.akkamo,
    "eu.akkamo" %% "akkamo-akka-http" % Versions.akkamo,
    "eu.akkamo" %% "akkamo-reactivemongo" % Versions.akkamo
  )
)/*.dependsOn(numbers)*/.dependsOn(csv).enablePlugins(AkkamoSbtPlugin)
