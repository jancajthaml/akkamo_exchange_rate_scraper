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

class CzechoMoravianMorgadgeBankActor() extends Actor with ActorLogging {

  private implicit val as: ActorSystem = context.system
  private implicit val eCtx: ExecutionContextExecutor = as.dispatcher
  private implicit val materializer = ActorMaterializer()

  // TODO parametrize hardcoded date parameters
  private val ratesUri: String = s"https://www.csob.cz/portal/lide/produkty/kurzovni-listky/kurzovni-listek/-/date/kurzy.txt"

  override def receive: Receive = {
    case CzechoMoravianMorgadgeBankActor.Fetch =>
      log.info("Performing fetch operation...")
      Http().singleRequest(HttpRequest(
        method = HttpMethods.GET,
        uri = ratesUri
      )) flatMap processResponse
  }

  private def processResponse(response: HttpResponse): Future[Unit] = {
    Unmarshal(response.entity).to[String] map { raw =>
      val data = csv(raw, ';', Map(
        "Množství" -> "AM", //amount
        "Měna" -> "CR", //currency
        "Nákup" -> "BD", //buy deviza
        "Prodej" -> "SD", //sell seviza
        "Nákup" -> "BV", //buy valuta
        "Prodej" -> "SV" //sell valuta
      ))//.drop(3).take(9)

      println("\n##### CSOB BANK RATES:")

      for (i <- data.toSeq) {
        println(i.map(pair => s"${pair._1}=${pair._2}").mkString("",", ",""))
      }
    }

    Future.successful()
  }
}

object CzechoMoravianMorgadgeBankActor {
  def props(): Props = Props(new CzechoMoravianMorgadgeBankActor())

  case object Fetch

}
