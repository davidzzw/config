Document 类似于 Record
Type 类似于 Table
Index 类似于 Database

ps aux |grep elasticsearch

kill -7 pid

elsearch
-d

#### 查询

* 布尔匹配查询
* 短语匹配查询(match_phrase)
* 短语前缀匹配查询(match_phrase_prefix)
* 多字段匹配查询



safe_info/safe_info/_delete_by_query?conflicts=proceed //删除type下的所有数据
{
  "query": {
    "match_all": {}
  }
}

./filebeat -e -c filebeat.yml -d "publish"

启动elasticsearch-head
npm run start

http://172.20.7.49:9200/_template  //查看默认模板

curl -XGET 'http://172.20.7.49:9200/_analyze?pretty&analyzer=standard' -d '第二更新'

//查询所有
curl -XPOST 'localhost:9200/bank/_search?pretty' -d '
{
  "query": { "match_all": {} }
}'

//插入数据
172.20.7.49:9200/test/time/1{
}

logger -p info "December 15th 2017, 16:14:21.331 info 172.20.7.15  Starting Session 422 of user root."
"message" => {"%{NUMBER:timestamp}  %{IP:client} %{WORD:data}"}

%{TIMESTAMP_ISO8601:time} %{WORD:level} %{IP:client}

add_field => {
                timestamp => "-"
                loglevel => "-"
                clientIp => "-"
                data => "-"
             }
%$NOW% %TIMESTAMP:8:15%

增加index
172.20.7.49:9200/test put

增加一个mapping
172.20.7.49:9200/test/time/_mapping?pretty" -d '   put
{
	"time": {
	        "properties": {
	            "time": {
	                "type": "date",
	                "format": "yyyy-MM-dd hh:mm:ss"
	            }
	        }
	    }
}
			"level": {
	            "type": "string",
	             "index": "not_analyzed"
	        },
			"client": {
	           "type": "string",
	            "index": "not_analyzed"
	        },
	    	"data": {
	            "type": "string",
	            "index": "not_analyzed
	        },
	        "time": {
	             "type": "date",
	             "format": "yyyy-MM-dd hh:mm:ss"
	        }


范围查找
172.20.7.49:9200/test/time/_search   post
{
	"query": {
	    "bool": {
	      "must": { "match_all": {} },
	      "filter": {
	        "range": {
	          "time": {
	            "gte": "2017-12-16 11:16:52",
	            "lte": "2017-12-16 11:16:52"
	          }
	        }
	      }
	    }
	  }
}


properties": {
                "host": {
                    "type": "string",
                    "index": "not_analyzed"
                },
                "type": {
                    "type": "string",
                    "index": "not_analyzed"
                },
                "@version": {
                    "type": "string",
                    "index": "not_analyzed"
                },
                "@timestamp": {
                    "format": "strict_date_optional_time||epoch_millis",
                    "type": "date"
                },
                "level": {
                    "type": "string",
                    "index": "not_analyzed"
                },
                "client": {
                    "type": "string",
                    "index": "analyzed"
                },
                "data": {
                    "type": "string",
                    "index": "not_analyzed"
                },
                "time": {
                  "format": "strict_date_optional_time||epoch_millis",
                    "type": "date"
                }
            }
    		
    		{
  "template": "my_index",
  "order": 1,
  "settings": {
    "index.refresh_interval" : "5s"
  },
  "mappings": {
    "_default_": {
      "properties": {
                "host": {
                    "type": "string",
                    "index": "not_analyzed"
                },
                "type": {
                    "type": "string",
                    "index": "not_analyzed"
                },
                "@version": {
                    "type": "string",
                    "index": "not_analyzed"
                },
                "@timestamp": {
                    "format": "strict_date_optional_time||epoch_millis",
                    "type": "date"
                },
                "level": {
                    "type": "string",
                    "index": "not_analyzed"
                },
                "client": {
                    "type": "string",
                    "index": "analyzed"
                },
                "data": {
                    "type": "string",
                    "index": "not_analyzed"
                },
                "time": {
                  "format": "strict_date_optional_time||epoch_millis",
                    "type": "date"
                }
        }
      }
    }
  }
}

{ 
    "template" : "qmpsearchlog", 
    "order":1,
    "settings" : { "index.refresh_interval" : "5s" }, 
    "mappings" : { 
        "_default_" : { 
            "_all" : { "enabled" : false }, 
            "dynamic_templates" : [{ 
              "message_field" : { 
                "match" : "message", 
                "match_mapping_type" : "string", 
                "mapping" : { "type" : "string", "index" : "not_analyzed" } 
              } 
            }, { 
              "string_fields" : { 
                "match" : "*", 
                "match_mapping_type" : "string", 
                "mapping" : { "type" : "string", "index" : "not_analyzed" } 
              } 
            }], 
            "properties" : { 
    			"host": {"type": "string","index": "not_analyzed"},
    			"index": {"type": "string","index": "not_analyzed"},
    			"type": {"type": "string","index": "not_analyzed"},
                "@timestamp" : { "type" : "date"}, 
                "@version" : { "type" : "integer", "index" : "not_analyzed" }, 
    			"level": {"type": "string","index": "not_analyzed"},
    			"client": {"type": "string","index": "not_analyzed"},
    			"data": {"type": "string","index": "not_analyzed"},
    			"time":{"type":"date","format": "yyy-MM-dd HH:mm:ss||yyyy-MM-dd||epoch_millis"}
            } 
        } 
    } 
}

  