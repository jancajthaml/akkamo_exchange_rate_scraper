package com.github.jancajthaml.scraper.rates

import akka.actor.{Actor, ActorLogging, ActorSystem, Props}
import akka.http.scaladsl.Http
import akka.http.scaladsl.model.{HttpMethods, HttpRequest, HttpResponse}
import akka.stream.scaladsl.Sink

import akka.http.scaladsl.unmarshalling.Unmarshal
import akka.http.scaladsl.unmarshalling._
import akka.stream.ActorMaterializer

import com.github.jancajthaml.csv.{read => csv}

import scala.concurrent.{ExecutionContextExecutor, Future}

class CityBankActor() extends Actor with ActorLogging {

  private implicit val as: ActorSystem = context.system
  private implicit val eCtx: ExecutionContextExecutor = as.dispatcher
  private implicit val materializer = ActorMaterializer()

  // TODO parametrize hardcoded date parameters
  private val ratesUri: String = s"http://www.citibank.cz/czech/gcb/personal_banking/data/rates.txt"

  override def receive: Receive = {
    case CityBankActor.Fetch =>
      log.info("Performing fetch operation...")
      Http().singleRequest(HttpRequest(
        method = HttpMethods.GET,
        uri = ratesUri
      )) flatMap processResponse
  }

  private def processResponse(response: HttpResponse): Future[Unit] = {
    Unmarshal(response.entity).to[String] map { raw =>
      val data = csv(raw, ',', Map(
        10 -> "BD", //buy deviza
        11 -> "SD", //sell deviza
        12 -> "BV", //buy valuta
        13 -> "SV", //sell valuta
        15 -> "CR" //currency
      )).filterNot(_.isEmpty).drop(2).dropRight(1)

      val date = csv(raw, ',', Map(
        11 -> "Date" //created at
      )).filterNot(_.isEmpty).takeRight(1)

      println("\n##### CITY BANK RATES:")

      for (i <- data.toSeq) {
        println(i.map(pair => s"${pair._1}=${pair._2}").mkString("",", ",""))
      }
      for (i <- date.toSeq) {
        println(i.map(pair => s"${pair._1}=${pair._2}").mkString("",", ",""))
      }
    }

    Future.successful(())
  }
}

object CityBankActor {
  def props(): Props = Props(new CityBankActor())

  case object Fetch

}
