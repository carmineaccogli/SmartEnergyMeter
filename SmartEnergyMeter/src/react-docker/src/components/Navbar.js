import React from 'react';
import './Navbar.css';
import Icon from "../images/fiwareICON.jpg";


function Navbar() {
  return (
    <nav>
      
      <div className="nav--logo" >
        <img className="nav--logo--image" src={Icon} alt="site logo" />
      </div>

      <div className="nav--text--container">
        <p className='nav--text'>Smart Energy Meter <br></br>DASHBOARD</p>
      </div>

    </nav>
  )
}

export default Navbar;
