package com.github.jancajthaml.scraper.exchange

import akka.actor.{ActorRef, ActorSystem}
import akka.event.LoggingAdapter
import eu.akkamo
import eu.akkamo._
import eu.akkamo.mongo.{ReactiveMongoApi, ReactiveMongoModule}

import scala.concurrent.ExecutionContextExecutor
import scala.concurrent.duration._

import com.github.jancajthaml.scraper.rates._

//import com.github.jancajthaml.number.Real

import scala.util.Try

class ExchangeRateScraperModule extends akkamo.Module with akkamo.Initializable with akkamo.Runnable {

  override def dependencies(dependencies: Dependency): Dependency = dependencies
      .&&[akkamo.AkkaModule].&&[akkamo.LogModule].&&[ReactiveMongoModule]

  override def initialize(ctx: Context): Res[Context] = Try {
    // inject dependencies
    val log: LoggingAdapter = ctx.get[LoggingAdapterFactory] apply getClass

    log.info("Initializing Exchange Scraper module")

    ctx
  }

  override def run(ctx: Context): Res[Context] = Try {

    //this will be somewhat shared and only keys would change for each Actor in utils folder
    val mongo: ReactiveMongoApi = ctx.get[ReactiveMongoApi](Keys.cityBankRate)
    val system: ActorSystem = ctx.get[ActorSystem](Keys.cityBankRate)

    implicit val eCtx: ExecutionContextExecutor = system.dispatcher
/*
    val cityBankActor: ActorRef = system.actorOf(CityBankActor.props())
    system.scheduler.schedule(5.seconds, 1.seconds, cityBankActor, CityBankActor.Fetch)

    val cnBankActor: ActorRef = system.actorOf(CzechNationalBankActor.props())
    system.scheduler.schedule(5.seconds, 1.seconds, cnBankActor, CzechNationalBankActor.Fetch)
*/
    val csBankActor: ActorRef = system.actorOf(CzechoSlovakBankActor.props())
    system.scheduler.schedule(5.seconds, 1.seconds, csBankActor, CzechoSlovakBankActor.Fetch)
/*
    val csobBankActor: ActorRef = system.actorOf(CzechoMoravianMorgadgeBankActor.props())
    system.scheduler.schedule(5.seconds, 1.seconds, csobBankActor, CzechoMoravianMorgadgeBankActor.Fetch)
*/
    ctx
  }
}