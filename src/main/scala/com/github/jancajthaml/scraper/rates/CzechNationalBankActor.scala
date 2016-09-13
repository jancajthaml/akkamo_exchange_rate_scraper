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

class CzechNationalBankActor() extends Actor with ActorLogging {

  private implicit val as: ActorSystem = context.system
  private implicit val eCtx: ExecutionContextExecutor = as.dispatcher
  private implicit val materializer = ActorMaterializer()

  // TODO parametrize hardcoded date parameters
  private val ratesUri: String = s"https://www.cnb.cz/cs/financni_trhy/devizovy_trh/kurzy_devizoveho_trhu/denni_kurz.txt?date=12.08.2016"

  import CzechNationalBankActor.Fetch

  override def receive: Receive = {
    case Fetch =>
      log.info("Performing fetch operation...")
      Http().singleRequest(HttpRequest(
        method = HttpMethods.GET,
        uri = ratesUri
      )) flatMap processResponse
  }

  private def processResponse(response: HttpResponse): Future[Unit] = {
    Unmarshal(response.entity).to[String] map { raw =>
        
      println("RECIEVED RESPONSE:" + raw)

      /*val data = csv(raw, ',', Map(
        "COL9" -> "BD", //buy deviza
        "COL10" -> "SD", //sell deviza
        "COL11" -> "BV", //buy valuta
        "COL12" -> "SV", //sell valuta
        "COL14" -> "CR" //currency
      )).drop(3).take(9)

      println("\n##### CITY BANK RATES:")

      for (i <- data.toSeq) {
        println(i.map(pair => s"${pair._1}=${pair._2}").mkString("",", ",""))
      }
      */
    }

    Future.successful()
  }
}

object CzechNationalBankActor {
  def props(): Props = Props(new CzechNationalBankActor())

  case object Fetch

}

/*

//CSV based response

https://www.cnb.cz/cs/financni_trhy/devizovy_trh/kurzy_devizoveho_trhu/denni_kurz.txt?date=12.08.2016

12.08.2016 #156
země|měna|množství|kód|kurz
Austrálie|dolar|1|AUD|18,584
Brazílie|real|1|BRL|7,655
Bulharsko|lev|1|BGN|13,814
Čína|renminbi|1|CNY|3,644
Dánsko|koruna|1|DKK|3,632
EMU|euro|1|EUR|27,020
Filipíny|peso|100|PHP|51,989
Hongkong|dolar|1|HKD|3,122
Chorvatsko|kuna|1|HRK|3,607
Indie|rupie|100|INR|36,208
Indonesie|rupie|1000|IDR|1,845
Izrael|šekel|1|ILS|6,349
Japonsko|jen|100|JPY|23,747
Jihoafrická rep.|rand|1|ZAR|1,793
Jižní Korea|won|100|KRW|2,189
Kanada|dolar|1|CAD|18,659
Maďarsko|forint|100|HUF|8,715
Malajsie|ringgit|1|MYR|6,010
Mexiko|peso|1|MXN|1,325
MMF|SDR|1|XDR|33,756
Norsko|koruna|1|NOK|2,948
Nový Zéland|dolar|1|NZD|17,436
Polsko|zlotý|1|PLN|6,332
Rumunsko|nové leu|1|RON|6,060
Rusko|rubl|100|RUB|37,409
Singapur|dolar|1|SGD|17,982
Švédsko|koruna|1|SEK|2,865
Švýcarsko|frank|1|CHF|24,818
Thajsko|baht|100|THB|69,573
Turecko|lira|1|TRY|8,188
USA|dolar|1|USD|24,211
Velká Británie|libra|1|GBP|31,393

*/
