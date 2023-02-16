const URL = 'http://localhost:1026/v2/entities'



// API per ottenere le entità (nel nostro caso rooms) da orion
async function getEntities() {
    const response = await fetch(URL);
    const entitiesJSON = await response.json();
    if (response.ok) {
        return entitiesJSON.map((e) => ({id: e.id, name: e.name.value, temperature: e.temperature.value, CO2_level: e.CO2_level.value }) )
    } else {
        throw entitiesJSON;
    }
}

// API per ottenere il consumo con relativa unità di misura dal device multimetro
async function getConsume() {
    const settings = {
        method: 'GET',
        headers : {
            "fiware-service": "openiot",
            "fiware-servicepath": "/"
        }
    };
    const response = await fetch(URL+'/urn:ngsi-ld:Device:multimeter001', settings);
    const device = await response.json();
    if (response.ok) {
        return ({totalConsume: device.consume.value, unitCodeConsume: device.consume.metadata.unitCode.value }) 
    } else {
        throw device;
    }
}

// API per ottenere le informazioni sullo stato degli HVAC presenti
async function getHVAC_status() {
    const settings = {
        method: 'GET',
        headers : {
            "fiware-service": "openiot",
            "fiware-servicepath": "/"
        }
    };
    const response = await fetch(URL, settings);
    const hvacStatus = await response.json();
    if (response.ok) {
        return hvacStatus.filter(function (obj) { 
            return obj.id.includes("urn:ngsi-ld:Device:hvac")}).sort (function (a,b) {
                var collator = new Intl.Collator([], {numeric: true});
                return collator.compare(a.id, b.id)}).map((h) => (
                    {id: h.id, cooling_info: h.cooling_info.value, heating_info: h.heating_info.value, ventilation_info: h.ventilationON_info.value, refRoom: h.refRoom.value}) )
    } else {
        throw hvacStatus;
    }
}

// API per ottenere le informazioni sui sensori di temperatura presenti
async function getDeviceTemperature() {
    const settings = {
        method: 'GET',
        headers : {
            "fiware-service": "openiot",
            "fiware-servicepath": "/"
        }
    };
    const response = await fetch(URL, settings);
    const hvacStatus = await response.json();
    if (response.ok) {
        return hvacStatus.filter(function (obj) { 
            return obj.id.includes("urn:ngsi-ld:Device:temperature")}).sort (function (a,b) {
                var collator = new Intl.Collator([], {numeric: true});
                return collator.compare(a.id, b.id)}).map((t) => (
                    {id: t.id, temperature: t.temperature.value, unitCode: t.temperature.metadata.unitCode.value, refRoom: t.refRoom.value}) )
    } else {
        throw hvacStatus;
    }
}

// API per ottenere le informazioni sui sensori di qualità dell'aria presenti
async function getDeviceAirquality() {
    const settings = {
        method: 'GET',
        headers : {
            "fiware-service": "openiot",
            "fiware-servicepath": "/"
        }
    };
    const response = await fetch(URL, settings);
    const hvacStatus = await response.json();
    if (response.ok) {
        return hvacStatus.filter(function (obj) { 
            return obj.id.includes("urn:ngsi-ld:Device:airquality")}).sort (function (a,b) {
                var collator = new Intl.Collator([], {numeric: true});
                return collator.compare(a.id, b.id)}).map((a) => (
                    {id: a.id, CO2_level: a.CO2_level.value, unitCode: a.CO2_level.metadata.unitCode.value, refRoom: a.refRoom.value}) )
    } else {
        throw hvacStatus;
    }
}





const API = {getEntities, getConsume, getHVAC_status, getDeviceTemperature, getDeviceAirquality}
export default API