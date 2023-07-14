def url_to_mobile(url):
    return url.replace('wikipedia.org', 'm.wikipedia.org') + '#content'


def url_to_dbpedia(url):
    return 'http://dbpedia.org/page/' + url.split('wiki/')[1]


class ResultsException(Exception):
    def __init__(self, query):
        self.message = "'{0}' not found".format(query)


class RequestException(Exception):
    def __init__(self, request):
        self.message = ('Endpoint not answering ({0})'
                        .format(request.url.split('?')[0]))


language_codes = ['en', 'de', 'fr', 'es', 'ru', 'ja', 'nl', 'it', 'sv', 'pl',
                  'vi', 'pt', 'ar', 'zh', 'uk', 'ca', 'no', 'fi', 'cs', 'hu',
                  'tr', 'ko', 'id', 'he', 'fa', 'ceb', 'ro', 'da', 'eo', 'sr',
                  'lt', 'sk', 'bg', 'sl', 'eu', 'et', 'hr', 'te', 'nn', 'th',
                  'gl', 'el', 'simple', 'ms', 'bs', 'ka', 'is', 'sq', 'la',
                  'hi', 'az', 'bn', 'mk', 'mr', 'sh', 'tl', 'cy', 'lv', 'ta',
                  'be', 'af', 'zh-yue', 'ur', 'bal', 'hy', 'kn', 'ml', 'ne',
                  'sa', 'sco', 'war', 'sw', 'vo', 'lmo', 'new', 'ht', 'bpy',
                  'lb', 'br', 'io', 'pms', 'su', 'oc', 'jv', 'nap', 'nds',
                  'scn', 'ast', 'ku', 'wa', 'an', 'ksh', 'szl', 'fy', 'frr',
                  'ia', 'ga', 'yi', 'als', 'am', 'map-bms', 'bh', 'co', 'cv',
                  'nds-nl', 'fo', 'glk', 'gu', 'ilo', 'pam', 'csb', 'km', 'lij',
                  'li', 'gv', 'mi', 'mt', 'nah', 'nrm', 'se', 'nov', 'qu', 'os',
                  'ps', 'pdc', 'rm', 'bat-smg', 'gd', 'sc', 'si', 'tg',
                  'roa-tara', 'tt', 'tk', 'hsb', 'uz', 'vec', 'fiu-vro', 'wuu',
                  'vls', 'yo', 'diq', 'zh-min-nan', 'zh-classical', 'frp',
                  'lad', 'bar', 'bcl', 'kw', 'mn', 'ang', 'ln', 'ie', 'crh',
                  'ay', 'zea', 'eml', 'ky', 'or', 'mg', 'arc', 'gn', 'so',
                  'kab', 'stq', 'ce', 'udm', 'mzn', 'cu', 'sah', 'tet', 'sd',
                  'lo', 'ba', 'pnb', 'na', 'got', 'bo', 'dsb', 'cdo', 'hak',
                  'om', 'my', 'pcd', 'ug', 'as', 'av', 'zu', 'pnt', 'pih', 'bi',
                  'ch', 'arz', 'xh', 'kl', 'kv', 'xal', 'bxr', 'ak', 'ab', 'za',
                  'ha', 'rn', 'chy', 'mwl', 'pa', 'xmf', 'lez', 'bjn', 'mai',
                  'gom', 'lrc', 'tyv', 'min', 'vep', 'kbd', 'rue', 'gag', 'koi',
                  'mrj', 'mhr', 'krc', 'ckb', 'ace', 'gan', 'hif', 'kaa', 'myv',
                  'azb', 'be-x-old', 'roa-rup', 'dv', 'fur', 'pi', 'pag', 'to',
                  'haw', 'wo', 'tpi', 'ty', 'jbo', 'ig', 'cbk-zam', 'kg', 'rmy',
                  'ks', 'pap', 'iu', 'chr', 'sm', 'ee', 'ti', 'bm', 'nv', 'cr',
                  'ss', 've', 'rw', 'ik', 'bug', 'dz', 'ts', 'tn', 'tum', 'st',
                  'tw', 'ny', 'fj', 'lbe', 'ki', 'ff', 'lg', 'sn', 'sg', 'nso',
                  'ltg', 'pfl', 'mdf', 'srn', 'ady', 'tcy']
