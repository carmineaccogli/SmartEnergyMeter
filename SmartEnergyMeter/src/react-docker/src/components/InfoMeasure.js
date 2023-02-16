import React from 'react';
import './InfoMeasure.css';
import multimeterSensorICON from "../images/multimeterSensorICON";
import summerICON from "../images/summerICON";
import winterICON from "../images/winterICON";

//Componente che implementa la renderizzazione condizionale. 
//In base al type passato verranno renderizzate solamente le parti interessate per modellare il componente di quel type

function InfoMeasure(props) {

  //props passate al componente da App.js
  let type = props.info;
  let multiInfo = props.multimeterInfo;
  let currentSeason = props.currentSeason

  return (
    <div className="info--container">

      <div className="info--img--container">
        {type=="energy" ?
        <img className="info--img energy" src={multimeterSensorICON}></img>
        : currentSeason ==="summer" ? <img className="info--img season-sun" src={summerICON}></img> : 
        <img className="info--img season-winter" src={winterICON}></img> 
      }
      </div>


      <div className="info--text--container">
        {type=="season" ?
          <p className="info--text">Current season: {currentSeason} </p>
          : <p className="info--text">Total Consumed: {multiInfo.totalConsume} {multiInfo.unitCodeConsume} </p>
        }
      </div>

      
    </div>
  )
}

export default InfoMeasure;
