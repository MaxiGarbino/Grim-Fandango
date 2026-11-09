class Alma {
  var property dineroAlMorir
  var property accionesBuenas

  method capital() = dineroAlMorir + accionesBuenas
  
  method descontarCapital(cuanto) {
    dineroAlMorir = 0.max(dineroAlMorir - cuanto)
  }
}

class Venta {
  const property paquete
  const property alma
  
  method costo() = paquete.costoPara(alma)
}

class Agente {
  var property vendidos = []
  var property deuda 
  var property estrategia

  method venderPaquete(alma, paquete) {
    const unaVenta = new Venta(alma = alma, paquete = paquete)
    if (alma.capital() >= unaVenta.costo()) {
      vendidos.add(unaVenta)
      alma.descontarCapital(unaVenta.costo())
    } else {
      self.error("El alma no tiene plata suficiente")
    }
  }
  method atender(alma) {
    const paqueteElegido = estrategia.paqueteAOfrecer(alma)
    self.venderPaquete(alma, paqueteElegido)
  }

  method dineroGanado() = vendidos.sum({ venta => venta.costo() })
  method deudaActual() = deuda - self.dineroGanado()
  method estaLibre() = self.deudaActual() <= 0
}

object clasico{

  method paqueteAOfrecer(alma) {
    const posibles = departamento.paquetesDisponibles().filter({ p => alma.capital() >= p.costoPara(alma) })
    if (posibles.isEmpty()) {
      self.error("El alma no puede costear ningún paquete")
    }
    return posibles.max({ p => p.costoPara(alma) })
  }
}
object navegante{
  method paqueteAOfrecer(alma){
    if (alma.accionesBuenas() >= 50) {
      return new Crucero(costoBase = alma.accionesBuenas())
    } else {
      return new Bote(costoBase = alma.accionesBuenas())
    }
  }
}
object indiferente {
  method paqueteAOfrecer(alma) {
    const costoAleatorio = 1.randomUpTo(301).truncate(0)
    return new Palo(costoBase = costoAleatorio)
  }
}

object departamento {
  var property agentes = []
  const property paquetesDisponibles = []

  method mejorAgente() = agentes.max({ agente => agente.vendidos().size() })
  
  method diaMuertos() {
    const mejor = self.mejorAgente()
    mejor.deuda(mejor.deuda() - 50)

    const agentesQueSiguen = []

    agentes.forEach({ agente =>
      if (!agente.estaLibre()) {
        agente.deuda(agente.deuda() + 100)
        agentesQueSiguen.add(agente)
      }
    })

    agentes = agentesQueSiguen
  }
}
class Paquete {
  var costoBase

  method reduccionAnios(alma)
  
  method costoPara(alma) {
    return 350.min(costoBase * self.reduccionAnios(alma))
  }
}

class Tren inherits Paquete {
  override method reduccionAnios(alma) = 4
}

class Bote inherits Paquete {
  override method reduccionAnios(alma) = 2.min(alma.accionesBuenas() / 50)
}

class Crucero inherits Bote {
  override method reduccionAnios(alma) = super(alma) * 2
}

class Palo inherits Paquete{
  override method reduccionAnios(alma) = 0.05
  override method costoPara(alma) = costoBase
}