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
        "Jednotka" -> "AM"
        "Měna" -> "CR", //currency
        "Nákup" -> "BD", //buy deviza
        "Prodej" -> "SD", //sell deviza
        "Nákup" -> "BV", //buy valuta
        "Prodej" -> "SV", //sell valuta
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


/*

//CSV based response

https://www.csas.cz/banka/portlets/exchangerates/current.do?csv=1&times=&event=current&day=12&month=8&year=2016


"Platnost od:","12.8.2016" ,""," "," ","Devizy"," "," ","Valuty"," "," ","ÈNB",
"Zemì","Jednotka","Mìna","Zmìna [%]", ,"Nákup","Prodej","Støed","Nákup","Prodej","Støed","Støed",
Austrálie,"1","AUD","-0.05","-","18.214","19.148","18.681","18.03","19.33","18.681","18.686",
Bulharsko,"1","BGN","0.05","+","13.474","14.165","13.82","-","-","-","13.813",
Kanada,"1","CAD","0.29","+","18.122","19.052","18.587","17.94","19.24","18.587","18.562",
Švýcarsko,"1","CHF","0.41","+","24.26","25.504","24.882","24.16","25.6","24.882","24.884",
Dánsko,"1","DKK","0.06","+","3.543","3.724","3.634","3.51","3.76","3.634","3.632",
EU,"1","EUR","0.04","+","26.354","27.706","27.03","26.3","27.76","27.03","27.02",
Velká Británie,"1","GBP","-0.35","-","30.614","32.184","31.399","30.46","32.34","31.399","31.403",
Hong Kong,"1","HKD","0.13","+","3.043","3.199","3.121","-","-","-","3.123",
Chorvatsko,"1","HRK","-0.06","-","3.518","3.698","3.608","3.52","3.72","3.608","3.604",
Maïarsko,"100","HUF","0.08","+","8.495","8.93","8.713","8.49","8.97","8.713","8.709",
Japonsko,"100","JPY","0.1","+","23.309","24.504","23.907","23.07","24.74","23.907","23.903",
Norsko,"1","NOK","0.44","+","2.866","3.013","2.94","2.84","3.04","2.94","2.927",
Nový Zéland,"1","NZD","0.34","+","17.12","17.998","17.559","-","-","-","17.559",
Polsko,"1","PLN","0.03","+","6.183","6.5","6.342","6.16","6.53","6.342","6.342",
Rumunsko,"1","RON","0.07","+","5.912","6.216","6.064","-","-","-","6.058",
Rusko,"100","RUB","-0.23","-","35.958","38.954","37.456","-","-","-","37.339",
Švédsko,"1","SEK","0.49","+","2.8","2.944","2.872","2.77","2.97","2.872","2.865",
Tunisko,"1","TND","0.17","+","10.7","11.249","10.974","-","-","-","-",
Turecko,"1","TRY","0.12","+","7.979","8.388","8.184","-","-","-","8.176",
USA,"1","USD","0.1","+","23.599","24.809","24.204","23.5","24.91","24.204","24.224",
JAR,"1","ZAR","0.05","+","1.775","1.866","1.821","-","-","-","1.813",

*/


/*
#!/bin/bash  

. common.sh

syncDate="12.8.2016"

if online; then
  day=$(cut -d "." -f 1 <<< $syncDate)
  month=$(cut -d "." -f 2 <<< $syncDate)
  year=$(cut -d "." -f 3 <<< $syncDate)

  day=${day#0}
  month=${month#0}
  year=${year#0}

  response=$(request "https://www.csas.cz/banka/portlets/exchangerates/current.do?csv=1&times=&event=current&day=${day}&month=${month}&year=${year}")

  if [ $? -eq 0 ]; then
    data=$(iconv -f ASCII --byte-subst='\x{%02x}' <<< "$response" | tr -d "\"" | tr -d ' ')

    #"Platnost od:","12.8.2016" ,""," "," ","Devizy"," "," ","Valuty"," "," ","ČNB",
    check=$(head -n 1 <<< "$data")
    cols=$(tr -dc ',' <<< "$check" | wc -c | sed -e "s/ //g")
    IFS=',' read -r -a args <<< "$check"

    dataDate=${args[1]}

    if [[ ! "$syncDate" == "$dataDate" ]]; then
      echo "no data for $syncDate"
      exit 1
    fi

    data=$(tail -n +3 <<< "$data")
    flat=$(tr -d "\n\r" <<< "$data")
    rows=$(wc -l <<< "$data" | sed -e "s/ //g")

    IFS=',' read -r -a args <<< "$flat"

    for ((row=0;row<$rows;row++)) do
      offset=$(bc -l <<< "$row * $cols")

      currencyTarget=${args[$((offset + 2))]}
      currencySource="CZK"

      amount=${args[$((offset + 1))]}

      normalizedAmount="1"

      #devizy nakup/prodej
      normalizedBuyDeviza=$(calculate "${args[$((offset + 6))]} / $amount")
      normalizedSellDeviza=$(calculate "${args[$((offset + 5))]} / $amount")

      #valuty nakup/prodej
      buyValuta=${args[$((offset + 9))]}
      sellValuta=${args[$((offset + 8))]}

      if [[ "$buyValuta" == "-" || "$sellValuta" == "-" ]]; then
        echo "$normalizedAmount $currencyTarget >> VIRTUAL_RATE { sell: $normalizedSellDeviza $currencySource, buy: $normalizedBuyDeviza $currencySource }, DATE: { $syncDate }"
      else
        normalizedBuyValuta=$(calculate "$buyValuta / $amount")
        normalizedSellValuta=$(calculate "$sellValuta / $amount")

        echo "$normalizedAmount $currencyTarget >> VIRTUAL_RATE { sell: $normalizedSellDeviza $currencySource, buy: $normalizedBuyDeviza $currencySource }, CASH_RATE { sell: $normalizedSellValuta $currencySource, buy: $normalizedBuyValuta $currencySource }, DATE: { $syncDate }"
      fi
    done

    exit 0
  else
    echo "network unreachable, bailing out"
    exit 1
  fi
else
  echo "network offline, nothing to do"
fi


*/