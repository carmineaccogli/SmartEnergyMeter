#!/bin/bash

# Funzione per la stampa dello Usage #
usage ()
{
    echo "Usage: $0 [start|stop]"
    exit 1
}

# Funzione per l'avvio dei container #
start ()
{
    echo "Starting containers:"

    docker-compose up --build -d

    init
}

# Funzione per lo stop e l'eliminazione dei container e dei volumi #
stop ()
{
    echo "Stopping containers"
    
    docker stop $(docker ps -a -q) >> /dev/null
    docker container prune -f >> /dev/null
    docker volume prune -f >> /dev/null

    echo "Containers stopped"

    exit 1
}

# Funzione per l'inizializzazione #
init ()
{
    #
    # Creazione delle entità 'room001' e 'room002'
    #
    curl -o /dev/null --silent -iX POST \
      --url 'http://localhost:1026/v2/op/update' \
      --header 'Content-Type: application/json' \
      --data ' {
      "actionType":"append",
      "entities":[
            {
            "id":"urn:ngsi-ld:Room:room001","type":"Room",
            "address":{
              "type":"PostalAddress",
              "value":{
                "streetAddress":"Viale Roma 12",
                "addressRegion":"Puglia",
                "addressLocality":"Lecce",
                "postalCode":"73100"
              }
            },
            "location":{
              "type":"geo:json","value":{
                "type":"Point",
                "coordinates":[40.36060,18.20347]
              }
            },
            "name":{
              "type":"Text",
              "value":"LivingRoom"
            },
            "temperature":{
              "type":"Number", 
              "value": 0,
              "metadata": {
                "unitCode": {
                  "type": "Text",
                  "value": "CEL"
                }
              }
            },
            "CO2_level":{
              "type":"Number", 
              "value": 0,
              "metadata": {
                "unitCode": {
                  "type": "Text",
                  "value": "ppm"
                }
              }
              },
            "refActuator":{
              "type":"Relationship",
              "value":"urn:ngsi-ld:Device:hvac001"
              }
            },
            {
            "id":"urn:ngsi-ld:Room:room002","type":"Room",
            "address":{
              "type":"PostalAddress",
              "value":{
                "streetAddress":"Viale Roma 12",
                "addressRegion":"Puglia",
                "addressLocality":"Lecce",
                "postalCode":"73100"
              }
            },
            "location":{
              "type":"geo:json","value":{
                "type":"Point",
                "coordinates":[40.36060,18.20347]
              }
            },
            "name":{
              "type":"Text",
              "value":"Kitchen"
            },
            "temperature":{
              "type":"Number", 
              "value": 0,
              "metadata": {
                "unitCode": {
                  "type": "Text",
                  "value": "CEL"
                }
              }
            },
            "CO2_level":{
              "type":"Number", 
              "value": "0",
              "metadata": {
                "unitCode": {
                  "type": "Text",
                  "value": "ppm"
                }
              }
            },
            "refActuator":{
              "type":"Relationship",
              "value":"urn:ngsi-ld:Device:hvac002"
              }
            }       
        ]
      }'

    # Controllo sull'esito dell'inserimento #
    if [ $? -ne 0 ]
    then
        echo "Failed to create entities 'room001' and 'room002'"
        exit 1
    fi

    echo "Entities 'room001' and 'room002' created"


    #
    # Provisioning del Service Group per la definizione di una chiave di autenticazione
    #
    curl -o /dev/null --silent -iX POST \
      'http://localhost:4041/iot/services' \
      -H 'Content-Type: application/json' \
      -H 'fiware-service: openiot' \
      -H 'fiware-servicepath: /' \
      -d '{
    "services": [
      {
        "apikey":      "4jggokgpepnvsb2uv4s40d59ov",
        "cbroker":     "http://orion:1026",
        "entity_type": "Thing",
        "resource":    "/iot/json"
      }
    ]
    }'

    # Controllo sull'esito dell'inserimento #
    if [ $? -ne 0 ]
    then
        echo "Failed to create the Service Group"
        exit 1
    fi

    echo "Service Group created"

    #
    # Creazione delle entità sensore di temperatura 'temperature001' e 'tmperature002', 
    # sensore di air quality 'airquality001'
    # e 'airquality002', e sensore Multimeter 'multimeter001'
    #
    curl -o /dev/null --silent -iX POST \
      'http://localhost:4041/iot/devices' \
      -H 'Content-Type: application/json' \
      -H 'fiware-service: openiot' \
      -H 'fiware-servicepath: /' \
      -d '{
    "devices": [
      {
        "device_id":   "temperature001",
        "entity_name": "urn:ngsi-ld:Device:temperature001",
        "entity_type": "Device",
        "category": {
          "type": "Property",
          "value": ["sensor"]
        },
        "timezone":    "Europe/Berlin",
        "attributes": [
          {
              "object_id": "t",
              "name": "temperature",
              "type": "Number",
              "metadata": {
                "unitCode": {
                  "type": "Text",
                  "value": "CEL"
                }
              }
          }
        ],
        "static_attributes": [
          { "name":"refRoom", "type": "Relationship", "value": "urn:ngsi-ld:Room:room001"}
        ]
      },
      {
        "device_id":   "temperature002",
        "entity_name": "urn:ngsi-ld:Device:temperature002",
        "entity_type": "Device",
        "category": {
          "type": "Property",
          "value": ["sensor"]
        },
        "timezone":    "Europe/Berlin",
        "attributes": [
          {
              "object_id": "t",
              "name": "temperature",
              "type": "Number",
              "metadata": {
                "unitCode": {
                  "type": "Text",
                  "value": "CEL"
                }
              }              
          }
        ],
        "static_attributes": [
          { "name":"refRoom", "type": "Relationship", "value": "urn:ngsi-ld:Room:room002"}
        ]
      },
      {
        "device_id":   "airquality001",
        "entity_name": "urn:ngsi-ld:Device:airquality001",
        "entity_type": "Device",
        "category": {
          "type": "Property",
          "value": ["sensor"]
        },
        "timezone":    "Europe/Berlin",
        "attributes": [
          {
              "object_id": "l",
              "name": "CO2_level",
              "type": "Number",
              "metadata": {
                "unitCode": {
                  "type": "Text",
                  "value": "ppm"
                }
              }
              
          }
        ],
        "static_attributes": [
          { "name":"refRoom", "type": "Relationship", "value": "urn:ngsi-ld:Room:room001"}
        ]
      },
      {
        "device_id":   "airquality002",
        "entity_name": "urn:ngsi-ld:Device:airquality002",
        "entity_type": "Device",
        "category": {
          "type": "Property",
          "value": ["sensor"]
        },
        "timezone":    "Europe/Berlin",
        "attributes": [
          {
              "object_id": "l",
              "name": "CO2_level",
              "type": "Number",
              "metadata": {
                "unitCode": {
                  "type": "Text",
                  "value": "ppm"
                }
              }
          }
        ],
        "static_attributes": [
          { "name":"refRoom", "type": "Relationship", "value": "urn:ngsi-ld:Room:room002"}
        ]
      },
      {
        "device_id":   "multimeter001",
        "entity_name": "urn:ngsi-ld:Device:multimeter001",
        "entity_type": "Device",
        "category": {
          "type": "Property",
          "value": ["sensor"]
        },
        "timezone":    "Europe/Berlin",
        "attributes": [
          {
              "object_id": "c",
              "name": "consume",
              "type": "Number",
              "metadata": {
                "unitCode": {
                  "type": "Text",
                  "value": "kWh"
                }
              }
              
          }
        ],
        "static_attributes": [
          { "name":"refRoom", "type": "Relationship", "value": "urn:ngsi-ld:Room:room001"}
        ]
      }
    ]
    }
    '
    # Controllo sull'esito dell'inserimento #
    if [ $? -ne 0 ]
    then
        echo "Failed to create sensors 'temperature001', 'temperature002', 'airquality001', 'airquality002' and 'multimeter001'"
        exit 1
    fi

    echo "Sensors 'temperature001', 'temperature002', 'airquality001', 'airquality002' and 'multimeter001' created"

    #
    # Creazione dele entità 'hvac001' e 'hvac002'
    #
    curl -o /dev/null --silent -iX POST \
      'http://localhost:4041/iot/devices' \
      -H 'Content-Type: application/json' \
      -H 'fiware-service: openiot' \
      -H 'fiware-servicepath: /' \
      -d '{
      "devices": [
        {
          "device_id": "hvac001",
          "entity_name": "urn:ngsi-ld:Device:hvac001",
          "entity_type": "Device",
          "category": {
            "type": "Property",
            "value": ["HVAC"]
          },
          "transport": "HTTP",
          "endpoint": "http://hvac-actuator:80/iot/hvac001",
          "commands": [
            {"name": "cooling","type": "command"},
            {"name": "heating","type": "command"},
            {"name": "off","type": "command"},
            {"name": "ventilationON","type": "command"},
            {"name": "ventilationOFF","type": "command"}
          ],
          "static_attributes": [
            {"name":"refRoom", "type": "Relationship","value": "urn:ngsi-ld:Room:room001"}
          ]
        },
        {
          "device_id": "hvac002",
          "entity_name": "urn:ngsi-ld:Device:hvac002",
          "entity_type": "Device",
          "category": {
            "type": "Property",
            "value": ["HVAC"]
          },
          "transport": "HTTP",
          "endpoint": "http://hvac-actuator:80/iot/hvac002",
          "commands": [
            {"name": "cooling","type": "command"},
            {"name": "heating","type": "command"},
            {"name": "off","type": "command"},
            {"name": "ventilationON","type": "command"},
            {"name": "ventilationOFF","type": "command"}
          ],
          "static_attributes": [
            {"name":"refRoom", "type": "Relationship","value": "urn:ngsi-ld:Room:room002"}
          ]
        }
      ]
    }
    '
    # Controllo sull'esito dell'inserimento #
    if [ $? -ne 0 ]
    then
        echo "Failed to create actuators 'hvac001' and 'hvac002'"
        exit 1
    fi

    echo "Actuators 'hvac001' and 'hvac002' created"


    #
    # Creazione della Subscription Perseo-Orion sugli attributi 'temperature' e 'CO2_level' delle entità 'Room'
    #
    curl -o /dev/null --silent -iX POST \
    'http://localhost:1026/v2/subscriptions' \
    -H 'Content-Type: application/json' \
    -d '{
      "description": "Subscription to feed the CEP",
      "subject": {
        "entities": [
          {
            "idPattern": ".*",
            "type": "Room"
          }
        ],
        "condition": {
          "attrs": ["temperature", "CO2_level"]
        }
      },
      "notification": {
        "http": {
          "url": "http://perseo-fe:9090/notices"
        },
        "attrs": ["temperature", "refActuator", "CO2_level"]
      }
    }'


    # Controllo sull'esito dell'inserimento #
    if [ $? -ne 0 ]
    then
        echo "Failed to create a Subscription between Perseo and Orion"
        exit 1
    fi

    echo "Subscription between Perseo and Orion created"


    #
    # Creazione della regola 'coolingON': accendi in modalità 'cooling' quando la temperatura è > 35
    #
    curl -o /dev/null --silent -iX POST \
    'http://localhost:9090/rules' \
    -H 'Content-Type: application/json' \
    -d '{
      "name":"coolingON",
      "text":"select *, refActuator? as ActuatorID, temperature? as Temperature from iotEvent where (cast(cast(temperature?,String),double)>35 and type=\"Room\")",
      "action":{
          "type":"post",
          "parameters":{
            "url": "http://orion:1026/v2/entities/${ActuatorID}/attrs",
            "method": "PATCH",
            "headers": {
                "Content-type": "application/json",
                "fiware-service": "openiot",
                "fiware-servicepath": "/"
            },
            "json": {
                "cooling": {
                    "type" : "command",
                    "value" : ""
                    } 
            }
          }
      }
    }'

    # Controllo sull'esito dell'inserimento #
    if [ $? -ne 0 ]
    then
        echo "Failed to create 'coolingON' rule"
        exit 1
    fi

    echo "'coolingON' rule created"

    #
    # Creazione della regola 'heatingON': accendi in modalità 'heating' quando la temperatura è < 10
    #
    curl -o /dev/null --silent -iX POST \
    'http://localhost:9090/rules' \
    -H 'Content-Type: application/json' \
    -d '{
      "name":"heatingON",
      "text":"select *,refActuator? as ActuatorID, temperature? as Temperature from iotEvent where (cast(cast(temperature?,String),double)<10 and type=\"Room\")",
      "action":{
          "type":"post",
          "parameters":{
            "url": "http://orion:1026/v2/entities/${ActuatorID}/attrs",
            "method": "PATCH",
            "headers": {
                "Content-type": "application/json",
                "fiware-service": "openiot",
                "fiware-servicepath": "/"
            },
            "json": {
                "heating": {
                    "type" : "command",
                    "value" : ""
                    } 
            }
          }
      }
    }'

    # Controllo sull'esito dell'inserimento #
    if [ $? -ne 0 ]
    then
        echo "Failed to create 'heatingON' rule"
        exit 1
    fi

    echo "'heatingON' rule created"


    #
    # Creazione della regola 'off': spegni l'HVAC quando la temperatura è compresa tra 15 e 25
    #
    curl -o /dev/null --silent -S -iX POST \
    'http://localhost:9090/rules' \
    -H 'Content-Type: application/json' \
    -d '{
      "name":"off",
      "text":"select *,refActuator? as ActuatorID, temperature? as Temperature from iotEvent where (cast(cast(temperature?,String),double) between 15 and 25 and type=\"Room\")",
      "action":{
          "type":"post",
          "parameters":{
            "url": "http://orion:1026/v2/entities/${ActuatorID}/attrs",
            "method": "PATCH",
            "headers": {
                "Content-type": "application/json",
                "fiware-service": "openiot",
                "fiware-servicepath": "/"
            },
            "json": {
                "off": {
                    "type" : "command",
                    "value" : ""
                    } 
            }
          }
      }
    }'

    # Controllo sull'esito dell'inserimento #
    if [ $? -ne 0 ]
    then
        echo "Failed to create 'off' rule"
        exit 1
    fi

    echo "'off' rule created"


    #
    # Creazione della regola 'ventilationON': accendi la ventilazione quando il livello di CO2 è > 1000
    #
    curl -o /dev/null --silent -S -iX POST \
    'http://localhost:9090/rules' \
    -H 'Content-Type: application/json' \
    -d '{
      "name":"ventilationON",
      "text":"select *,refActuator? as ActuatorID, CO2_level? as CO2 from iotEvent where (cast(cast(CO2_level?,String),double) > 1000 and type=\"Room\")",
      "action":{
          "type":"post",
          "parameters":{
            "url": "http://orion:1026/v2/entities/${ActuatorID}/attrs",
            "method": "PATCH",
            "headers": {
                "Content-type": "application/json",
                "fiware-service": "openiot",
                "fiware-servicepath": "/"
            },
            "json": {
                "ventilationON": {
                    "type" : "command",
                    "value" : ""
                    } 
            }
          }
      }
    }'

    # Controllo sull'esito dell'inserimento #
    if [ $? -ne 0 ]
    then
        echo "Failed to create 'ventilationON' rule"
        exit 1
    fi

    echo "'ventilationON' rule created"

    #
    # Creazione della regola 'ventilationOFF': spegni la ventilazione quando il livello di CO2 è < 600
    #
    curl -o /dev/null --silent -S -iX POST \
    'http://localhost:9090/rules' \
    -H 'Content-Type: application/json' \
    -d '{
      "name":"ventilationOFF",
      "text":"select *,refActuator? as ActuatorID, CO2_level? as CO2 from iotEvent where (cast(cast(CO2_level?,String),double) < 600 and type=\"Room\")",
      "action":{
          "type":"post",
          "parameters":{
            "url": "http://orion:1026/v2/entities/${ActuatorID}/attrs",
            "method": "PATCH",
            "headers": {
                "Content-type": "application/json",
                "fiware-service": "openiot",
                "fiware-servicepath": "/"
            },
            "json": {
                "ventilationOFF": {
                    "type" : "command",
                    "value" : ""
                    } 
            }
          }
      }
    }'

    # Controllo sull'esito dell'inserimento #
    if [ $? -ne 0 ]
    then
        echo "Failed to create 'ventilationOFF' rule"
        exit 1
    fi

    echo "'ventilationOFF' rule created"

    curl -o /dev/null --silent -S -iX DELETE \
    'http://localhost:1026/v2/entities' \
    -H 'fiware-service: openiot' \
    -H 'fiware-servicepath: /'
    

    exit 0
}




# Controllo sul numero di argomenti #
if [ $# -ne 1 ]
then
    usage
    exit 1
fi

# L'argomento passato è 'start' #
if [[ ( $1 == "start" ) ]]; 
then
    start
fi

# L'argomento passato è 'stop' #
if [[ ( $1 == "stop" ) ]]; 
then
    stop
fi

# L'argomento passato è sbagliato #
if [[ ( $1 != "start" && $1 != "stop" ) ]];
then
    usage
    exit 1
fi