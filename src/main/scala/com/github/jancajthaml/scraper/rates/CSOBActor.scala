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

class CSOBActorActor() extends Actor with ActorLogging {

  private implicit val as: ActorSystem = context.system
  private implicit val eCtx: ExecutionContextExecutor = as.dispatcher
  private implicit val materializer = ActorMaterializer()

  // TODO parametrize hardcoded date parameters
  private val ratesUri: String = s"https://www.csob.cz/portal/lide/produkty/kurzovni-listky/kurzovni-listek/-/date/kurzy.txt"

  override def receive: Receive = {
    case CSOBActorActor.Fetch =>
      log.info("Performing fetch operation...")
      Http().singleRequest(HttpRequest(
        method = HttpMethods.GET,
        uri = ratesUri
      )) flatMap processResponse
  }

  private def processResponse(response: HttpResponse): Future[Unit] = {
    Unmarshal(response.entity).to[String] map { raw =>
      //Země;Množství;Měna;Změna;Nákup;Prodej;Střed;Nákup;Prodej;Střed

      val data = csv(raw, ';', Map(
        2 -> "AM", //amount
        3 -> "CR", //currency
        5 -> "BD", //buy deviza
        6 -> "SD", //sell seviza
        8 -> "BV", //buy valuta
        9 -> "SV" //sell valuta
      )).drop(1)//.take(9)

      println("\n##### CSOB BANK RATES:")

      for (i <- data.toSeq) {
        println(i.map(pair => s"${pair._1}=${pair._2}").mkString("",", ",""))
      }
    }

    Future.successful(())
  }
}

object CSOBActorActor {
  def props(): Props = Props(new CSOBActorActor())

  case object Fetch

}
