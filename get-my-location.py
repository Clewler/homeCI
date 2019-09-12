
import sys
import json
import requests
import argparse


parser = argparse.ArgumentParser(description="Get localization of my phone using google API")

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
              "&appid="+api
    response = requests.get(request)
    return response

def post_to_elasticsearch(response):
    print(requests.post("http://192.168.1.20:5601/.kibana/1", data=response))
def main():
    city_id = getCityId("Szczecin")['id']

    response=setRequest(city_id,"f0c7c71bfe4570581ae87f1c6a9d8e2e")

    post_to_elasticsearch(response)
    pass

if __name__ == '__main__':
    main()
