import sys
import json
import requests
import datetime
import argparse
import uuid
from elasticsearch import Elasticsearch, helpers

parser = argparse.ArgumentParser(description="Get localization of my phone using google API")

CONF_FILE = "../cfg/conf.json"

with open(CONF_FILE, mode='r') as f:
    conf=json.loads(f.read())

def getCityId(city_name):
    """
    Find city in global city list, then return metadata
    """
    with open("current.city.list.json", encoding="utf-8", mode='r') as f:
        jsonCity = json.loads(f.read())

    for i in range(len(jsonCity)-1):
        if city_name == jsonCity[i]['name']:
            return jsonCity[i]

def setRequest(city_id,api):
    """
    Compose request to openweather api, and execute it
    then return
    """
    request = "http://api.openweathermap.org/data/2.5/weather?id="+\
              str(city_id)+\
              "&appid="+conf["weather-tracker"]['token']
    print(request)
    response = json.loads(requests.get(request).text)
    response['datetime'] = datetime.datetime.now()
    return response

def post_to_elasticsearch(body,city):
    es = Elasticsearch(hosts=[{'host':conf['es_ip'],'port':conf['es_port']}]
            ,http_auth=('user','u6PzFCh2GTcb'),
            verify_certs=True)
    es.index(index=conf["weather-tracker"]["weather-index"],doc_type=city,id=uuid.uuid4(), body=body)




def main():
    city_id = getCityId("Szczecin")['id']

    response=setRequest(city_id,"f0c7c71bfe4570581ae87f1c6a9d8e2e")

    post_to_elasticsearch(response,"Szczecin")
    pass

if __name__ == '__main__':
    main()
