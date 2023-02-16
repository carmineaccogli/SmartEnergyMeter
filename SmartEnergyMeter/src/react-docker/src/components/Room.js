import React from 'react';
import  tempSensorICON from "../images/tempSensorICON";
import  airqualitySensorICON from "../images/airqualitySensorICON";
import  hvacICON from "../images/hvacICON";
import  onICON from "../images/onICON";
import  offICON from "../images/offICON";
import './Room.css';




function Room(props) {

  //props passate al componente da App.js
  let entityInfo = props.entityInfo;
  let roomNumber = props.roomNumber;
  let hvacStatus = props.hvacStatus;
  let tempDeviceInfo =props.tempDeviceInfo;
  let airDeviceInfo =props.airDeviceInfo;



  return (
    <div className='room'>

    
      <section className="room--header">
        <h1>ROOM {roomNumber}</h1>
        <h3>{entityInfo.name}</h3>
      </section>

      <div className="room--sensors">

        <p className="room--index">Sensors:</p>

        <div className="room--sensors--temperature">
          <img className="room--sensors--icon" src={tempSensorICON}></img>
          <p className="room--sensors--text">TEMPERATURE: <br></br> {entityInfo.temperature} {tempDeviceInfo?.unitCode === "CEL" ? "°" : "F" }</p> 
        </div>
       
        <div className="room--sensors--airquality">
          <img className="room--sensors--icon" src={airqualitySensorICON}></img>
          <p className="room--sensors--text">CO2 LEVEL: <br></br> {entityInfo.CO2_level} {airDeviceInfo?.unitCode}</p>
        </div>
    
      </div>

      <div className="room--actuators">

        <p className="room--index">Actuators:</p>

        <div className="room--actuators--hvac">
          <img className="room--actuators--hvac--icon" src={hvacICON}></img>
          <div className="room--actuators--hvac--status">
            <div className="room--actuators-hvac-status-info">
              <p>COOLING:</p> 
              {hvacStatus?.cooling_info === "ON" ? <img src={onICON}></img> : <img src={offICON}></img> } 
            </div>
            <div className="room--actuators-hvac-status-info">
              <p>HEATING:</p>
              {hvacStatus?.heating_info === "ON" ? <img src={onICON}></img> : <img src={offICON}></img> }
            </div>
            <div className="room--actuators-hvac-status-info">
              <p>VENTILATION:</p>
              {hvacStatus?.ventilation_info === "true" ? <img src={onICON}></img> : <img src={offICON}></img>}
            </div>
          </div>
        </div>

      </div>

  
        
    </div>
  )
}



export default Room;