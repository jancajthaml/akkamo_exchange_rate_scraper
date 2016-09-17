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

class CzechoSlovakBankActor() extends Actor with ActorLogging {

  private implicit val as: ActorSystem = context.system
  private implicit val eCtx: ExecutionContextExecutor = as.dispatcher
  private implicit val materializer = ActorMaterializer()

  // TODO parametrize hardcoded date parameters
  private val ratesUri: String = s"https://www.csas.cz/banka/portlets/exchangerates/current.do?csv=1&times=&event=current&day=12&month=8&year=2016"

  override def receive: Receive = {
    case CzechoSlovakBankActor.Fetch =>
      log.info("Performing fetch operation...")
      Http().singleRequest(HttpRequest(
        method = HttpMethods.GET,
        uri = ratesUri
      )) flatMap processResponse
  }

  private def processResponse(response: HttpResponse): Future[Unit] = {
    Unmarshal(response.entity).to[String] map { raw =>
      //@info duplicate ordered keys
      val data = csv(raw, ',', Map(
        "Jednotka" -> "AM",
        "Měna" -> "CR", //currency
        "Nákup" -> "BD", //buy deviza
        "Prodej" -> "SD", //sell deviza
        "Nákup" -> "BV", //buy valuta
        "Prodej" -> "SV" //sell valuta
      )).drop(1)

      println("\n##### CS BANK RATES:")

      for (i <- data.toSeq) {
        println(i.map(pair => s"${pair._1}=${pair._2}").mkString("",", ",""))
      }
    }

    Future.successful()
  }
}

object CzechoSlovakBankActor {
  def props(): Props = Props(new CzechoSlovakBankActor())

  case object Fetch

}
