import './App.css';
import Navbar from "./components/Navbar.js";
import Room from "./components/Room.js";
import InfoMeasure from "./components/InfoMeasure.js";
import API from './API/API.js';
import { useEffect, useState }  from 'react';



function App() {

  //stato contenente l'array che viene restituito dalla API getEntities(): informazioni sulle entità rooms
  const [entitiesInfo, setEntitiesInfo] = useState([])

  //stato contenente le informazioni sul multimetro che vengono restituite dalla API getConsume(): consumo e unità di misura
  const [multimeterInfo, setMultimeterInfo] = useState([])

  //stato contenente l'array che viene restituito dalla API getHVAC_status(): stato degli HVAC
  const [hvacStatus, setHvacStatus] = useState([])

  //stato che viene aggiornato ogni 5 secondi per permettere di eseguire le API sincronizzandosi sulla frequenza di aggiornamento dei dati su ORION
  const [time, setTime] = useState(Date.now)

  //stato che contiene l'attuale stagione simulata
  const [currentSeason, setCurrentSeason] = useState([])

  //stato contenente l'array che viene restituito dalla API getDeviceTemperature(): temperatura e relativa unità di misura
  const [tempDevice, setTempDevice] = useState([])

  //stato contenente l'array che viene restituito dalla API getDeviceAirquality(): livello CO2 e relativa unità di misura
  const [airDevice, setAirDevice] = useState([])

  //stato usato per l'impostazione della stagione che diventa true quando la stagione è stata correttamente inizializzata
  const [dirty, setDirty] =useState(false)

  //condizione per controllare se i dati ricevuti dalla API sono undefined 
  const isSeasonReady = entitiesInfo[0]?.temperature !== undefined 

  
  //per controllare la condizione sopra vista e impostare dirty a true quando i dati sono stati caricati correttamente per impostare la stagione
  useEffect( () => {
    if (isSeasonReady) {
        setDirty(true)
    } 
  }, [isSeasonReady])


  //per aggiornare lo stato time ogni 5 secondi
  useEffect(() => {
    const interval = setInterval(() => setTime(Date.now()), 5000);
    return () => {
      clearInterval(interval);
    };
  }, []);


  //per aggiornare lo stato entitiesInfo ogni 5 secondi
  useEffect(() => {
    const prova = async() => {
        await API.getEntities()
            .then( (entities) => {setEntitiesInfo(entities);}
             )
            .catch( err => console.log(err))
    }
    prova()
  },[time])


  //per aggiornare lo stato multimeterInfo ogni 5 secondi
  useEffect(() => {
    const prova1 = async() => {
        await API.getConsume()
            .then( (multimeter) => {setMultimeterInfo(multimeter);} )
            .catch( err => console.log(err))
    }
    prova1()
  },[time])


  //per aggiornare lo stato hvacStatus ogni 5 secondi
  useEffect(() => {
    const prova2 = async() => {
        await API.getHVAC_status()
            .then( (hvac_state) => {setHvacStatus(hvac_state);}
              )
            .catch( err => {console.log(err);})
    }
    prova2()
  },[time])

  //per aggiornare lo stato tempDevice ogni 5 secondi
  useEffect(() => {
    const prova3 = async() => {
        await API.getDeviceTemperature()
            .then( (tempDevice) => {setTempDevice(tempDevice); }
              )
            .catch( err => console.log(err))
    }
    prova3()
  },[time])

  //per aggiornare lo stato airDevice ogni 5 secondi
  useEffect(() => {
  const prova4 = async() => {
      await API.getDeviceAirquality()
          .then( (airDevice) => {setAirDevice(airDevice); }
            )
          .catch( err => console.log(err))
  }
  prova4()
},[time])



  //per inizializzare la stagione
  useEffect(() => {
    const seas = () => {
    if (entitiesInfo[0]?.temperature > 25){
        setCurrentSeason("summer")
      }
      else{
        setCurrentSeason("winter")
      }
  }
    seas()
  }  ,[dirty])

  
  // variabili per impostare il tipo del componente favorendo la renderizzazione condizionale
  let typeSeason = "season"
  let typeConsume = "energy"

  return (
    <div className="app">
      <Navbar />  
     
        
      <div className="measureContainer">
        <InfoMeasure info={typeSeason} currentSeason={currentSeason} />
        <InfoMeasure info={typeConsume} multimeterInfo={multimeterInfo} />      
      </div>

      <div className="room--container">
        {entitiesInfo.map( (entity,index) => (
                <Room
                key={entity.id}
                entityInfo={entity}
                roomNumber={index+1}
                hvacStatus={hvacStatus.filter( function(hvac) {return hvac?.refRoom == entity.id})[0]}
                tempDeviceInfo={tempDevice.filter( function(temp) {return temp?.refRoom ==entity.id})[0]}
                airDeviceInfo={airDevice.filter( function(air) {return air?.refRoom == entity.id})[0]}
                 />
              ))}
      </div>
      
    </div>
  );
}

export default App;
