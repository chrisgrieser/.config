#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# giovanni from Clarence Castillo
# Wednesday, March 23, 2022

import requests
import logging
import json
import os

import sys

def log(s, *args):
    if args:
        s = s % args
    print(s, file=sys.stderr)



class PowerThesaurus:

    VERSION = open('./version').readline().strip()
    GQL_THESAURUS_QUERY = 'thesaurus_query'
    GQL_SEARCH_QUERY = 'search_query'
    VERIFY_SSL = os.getenv('ALFRED_PT_SSL_VERIFICATION') == '1'

    def __init__(self, api_url, web_url, gql_queries_dir='./gql_queries/', pos_file_path='./pos.json', logger=logging):
        self.api_url = api_url
        self.web_url = web_url
        self.logger = logger
        self.gql_queries = self.read_gql_queries(gql_queries_dir)
        self.pos_mapping = self.read_pos_mapping(pos_file_path)
        self.request_headers = self.build_request_headers()

    def build_url(self, slug, query_type):
        return '{}/{}/{}'.format(self.web_url, slug, query_type)

    def build_request_headers(self):
        return {
            'user-agent': 'Alfred-PowerThesaurus/' + PowerThesaurus.VERSION,
            'content-type': 'application/json'
        }

    def read_pos_mapping(self, file_path):
        pos_mapping = {}
        with open(file_path, 'r') as file:
            pos_list = json.loads(file.read())
            for pos in pos_list:
                pos_mapping[pos['id']] = pos
        return pos_mapping

    def read_gql_queries(self, dir):
        gql_queries = {}
        files = os.listdir(dir)

        for filename in files:
            file_path = os.path.join(dir, filename)
            with open(file_path, 'r') as file:

                key = os.path.splitext(filename)[0]
                gql_queries[key] = file.read()
        return gql_queries

    def build_search_query_params(self, query):
        #log('gql_query:{} '.format(self.gql_queries[PowerThesaurus.GQL_SEARCH_QUERY]))
        return {
            'operationName': 'SEARCH_QUERY',
            'variables': {
                'query': query
            },
            'query': self.gql_queries[PowerThesaurus.GQL_SEARCH_QUERY]

        }

    def build_thesaurus_query_params(self, term_id, query_type):
        return {
            'operationName': 'THESAURUSES_QUERY',
            'variables': {
                'list': query_type.upper(),
                'termID': term_id,
                'sort': {
                    'field': 'RATING',
                    'direction': 'DESC'
                },
                'limit': 50,
                'syllables': None,
                'query': None,
                'posID': None,
                'first': 50,
                'after': ''
            },
            'query': self.gql_queries[PowerThesaurus.GQL_THESAURUS_QUERY]
        }

    def parse_thesaurus_query_response(self, response):
        edges = response['data']['thesauruses']['edges']
        results = map(lambda e : e['node'], edges)
        return map(lambda r : {
            'id': r['targetTerm']['id'],
            'word': r['targetTerm']['name'],
            'slug': r['targetTerm']['slug'],
            'parts_of_speech': list(map(lambda p : self.pos_mapping[p]['shorter'], r['relations']['parts_of_speech'])),
            'tags': r['relations']['tags'],
            'synonyms_count': r['targetTerm']['counters']['synonyms'],
            'antonyms_count': r['targetTerm']['counters']['antonyms'],
            'rating': r['rating'],
            'url_synonyms': self.build_url(r['targetTerm']['slug'], 'synonyms'),
            'url_antonyms': self.build_url(r['targetTerm']['slug'], 'antonyms')
            }, results)

    def thesaurus_query(self, term_id, query_type):
        if not term_id:
            return []
        params = self.build_thesaurus_query_params(term_id, query_type)

        r = requests.post(self.api_url, json=params, headers=self.request_headers, verify=PowerThesaurus.VERIFY_SSL)
        r.raise_for_status()
        return self.parse_thesaurus_query_response(r.json())

    def parse_search_query_response(self, response):
        terms = response['data']['search']['terms']
        return map(lambda t : {
            'id': t['id'],
            'word': t['name'],
            }, terms)

    def search_query(self, query): # handles query submission, obtains and parses response (which is only the name and ID of the word)
        params = self.build_search_query_params(query)



        # query submission via requests
        r = requests.post(self.api_url, json=params, headers=self.request_headers, verify=PowerThesaurus.VERIFY_SSL)
        #log('checking search_query: {} {}'.format(r.status_code, r.url))
        r.raise_for_status()
        #log('JSON OUTPUT: {}'.format(r.json()))
        return self.parse_search_query_response(r.json())

    def search_query_match(self, query):   #handles query results
        terms = self.search_query(query)

        terms = list(terms) #need to covert back to a list because maps is not a list in Python3, it is a <map> object
        if not terms or terms[0]['word'] != query:
            return None
        return terms[0]
