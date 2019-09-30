from elasticsearch import Elasticsearch
from json import loads

CONF_FILE = "conf.json"

with open(CONF_FILE, mode='r') as f:
    conf=loads(f.read())

def addIndex(index, shards, replicas=1):

    es = Elasticsearch([{'host':conf['es_ip'],'port':conf['es_ip']}])
    response = es.indices.create(index = index, body = { "settings" : {
	                                               "number_of_shards": shards,
	                                               "number_of_replicas": replicas}
                                                   })
    print(response)

def main():
    addIndex(index, shards, replicas=1)


if __name__ == '__main__':
    main()
