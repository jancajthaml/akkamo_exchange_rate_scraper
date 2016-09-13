package com.github.jancajthaml.scraper.rates

import akka.actor.{Actor, ActorLogging, ActorSystem, Props}
import akka.http.scaladsl.Http
import akka.http.scaladsl.model.{HttpMethods, HttpRequest, HttpResponse}
  import akka.stream.scaladsl.Sink

import akka.http.scaladsl.unmarshalling.Unmarshal
import akka.http.scaladsl.unmarshalling._
import akka.stream.ActorMaterializer
import play.api.libs.json.JsValue

import scala.concurrent.{ExecutionContextExecutor, Future}

case class PlainText(status: String, error_msg: String)

class CityBankActor() extends Actor with ActorLogging {

  private implicit val as: ActorSystem = context.system
  private implicit val eCtx: ExecutionContextExecutor = as.dispatcher
  private implicit val materializer = ActorMaterializer()

  // TODO parametrize hardcoded date parameters
  private val ratesUri: String = s"http://www.citibank.cz/czech/gcb/personal_banking/data/rates.txt"

  import CityBankActor.Fetch
  import scala.concurrent.duration._

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
      println("RESPONSE RECEIVED: " + raw)
    }

    Future.successful()
  }
}

object CityBankActor {
  def props(): Props = Props(new CityBankActor())

  case object Fetch

}


/*

//CSV based response

http://www.citibank.cz/czech/gcb/personal_banking/data/rates.txt

ROW ID,COL1,COL2,COL3,COL4,COL5,COL6,COL7,COL8,COL9,COL10,COL11,COL12,COL13,COL14
'1,from 50 000,from 100 000,from 300 000,from 500 000,from 1 000 000,from 3 000 000,from 5 000 000,CZK,Buy NonCash,Sell NonCash,Buy Cash,Sell Cash,Middle,Currency
'2,0.00,0.00,0.00,0.00,0.00,0.00,0.00,7 days,23.3690,24.5920,23.1400,24.8200,23.9805,USD
'3,0.00,0.00,0.00,0.00,0.00,0.00,0.00,14 days,30.8250,32.5350,30.5700,32.7900,31.6800,GBP
'4,0.00,0.00,0.00,0.00,0.00,0.00,0.00,1 month,23.2370,24.5270,22.8100,24.9600,23.8820,JPY
'5,0.00,0.00,0.00,0.00,0.00,0.00,0.00,2 months,18.0700,19.0720,17.7400,19.4100,18.5710,CAD
'6,0.00,0.00,0.00,0.00,0.00,0.00,0.00,3 months,26.3310,27.7090,25.9400,28.1000,27.0200,EUR
'7,0.00,0.00,0.00,0.00,0.00,0.00,0.00,6 months,24.1380,25.4780,23.9400,25.6800,24.8080,CHF
'8,0.00,0.00,0.00,0.00,0.00,0.00,0.00,1 year,8.4930,8.9650,8.2500,9.2100,8.7290,HUF
'9,0.00,0.00,0.00,0.00,0.00,0.00,0.00,2 years,17.7960,18.7840,17.4700,19.1100,18.2900,AUD
'10,0.00,0.00,0.00,0.00,0.00,0.00,0.00,3 years,3.5320,3.7280,3.4700,3.7900,3.6300,DKK
'11,0.00,0.00,0.00,0.00,0.00,0.00,0.00,5 years,6.1060,6.4440,5.9300,6.6200,6.2750,PLN
'12,from 3 000,from 10 000,from 15 000,from 30 000,from 100 000,from 150 000,EUR,,2.7800,2.9340,2.7300,2.9900,2.8570,SEK
'13,0.00,0.00,0.00,0.00,0.00,0.00,7 days,,Date,25/08/2016,,,,
'14,0.00,0.00,0.00,0.00,0.00,0.00,14 days,,,,,,,
'15,0.00,0.00,0.00,0.00,0.00,0.00,1 month,,,,,,,
'16,0.00,0.00,0.00,0.00,0.00,0.00,2 months,,,,,,,
'17,0.00,0.00,0.00,0.00,0.00,0.00,6 months,,,,,,,
'18,0.00,0.00,0.00,0.00,0.00,0.00,1 year,,,,,,,
'19,0.00,0.00,0.00,0.00,0.00,0.00,2 years,,,,,,,
'20,0.00,0.00,0.00,0.00,0.00,0.00,3 years,,,,,,,
'21,0.00,0.00,0.00,0.00,0.00,0.00,5 years,,,,,,,
'22,from 2 500,from 7 500,from 12 500,from 25 000,from 75 000,from 125 000,USD,,,,,,,
'23,0.00,0.00,0.00,0.00,0.00,0.00,7 days,,,,,,,
'24,0.00,0.00,0.00,0.00,0.00,0.00,14 days,,,,,,,
'25,0.00,0.00,0.00,0.00,0.00,0.00,1 month,,,,,,,
'26,0.00,0.00,0.00,0.00,0.00,0.00,2 months,,,,,,,
'27,0.00,0.00,0.00,0.00,0.00,0.00,3 months,,,,,,,
'28,0.00,0.00,0.00,0.00,0.00,0.00,6 months,,,,,,,
'29,0.00,0.00,0.00,0.00,0.00,0.00,1 year,,,,,,,
'30,0.00,0.00,0.00,0.00,0.00,0.00,2 years,,,,,,,
'31,0.00,0.00,0.00,0.00,0.00,0.00,3 years,,,,,,,
'32,0.00,0.00,0.00,0.00,0.00,0.00,5 years,,,,,,,
'33,from 1 600,from 5 000,from 8 500,from 16 500,from 50 000,from 85 000,GBP,,,,,,,
'34,0.00,0.00,0.00,0.00,0.00,0.00,7 days,,,,,,,
'35,0.00,0.00,0.00,0.00,0.00,0.00,14 days,,,,,,,
'36,0.00,0.00,0.00,0.00,0.00,0.00,1 month,,,,,,,
'37,0.00,0.00,0.00,0.00,0.00,0.00,2 months,,,,,,,
'38,0.00,0.00,0.00,0.00,0.00,0.00,6 months,,,,,,,
'39,0.00,0.00,0.00,0.00,0.00,0.00,1 year,,,,,,,
'40,0.00,0.00,0.00,0.00,0.00,0.00,2 years,,,,,,,
'41,0.00,0.00,0.00,0.00,0.00,0.00,3 years,,,,,,,
'42,0.00,0.00,0.00,0.00,0.00,0.00,5 years,,,,,,,
'43,,,,,,,,,,,,,,
50,Test 1,Test 2,Test 3,Test 4,Test 5,Test 6,Test 7,Test 8,,,,,,

*/
