(: A lekérdezés eredménye egy XML dokumentum mely tartalmazza azon körözött személyekhez           :)
(: tartozó címet, mely körözések esetén az idén sikerült előrelépni. (idén történt                 :)
(: az adatokban módosítás) Ezen körözések száma a dokumentumba kerül a gyökérelem attribútumaként  :)

xquery version "3.1";

import schema default element namespace "" at "get_recently_updated_wanteds.xsd";

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "xml";
declare option output:indent "yes";

declare function local:get-recently-updated-wanteds($wanteds as item()*, $date-time as xs:date) as map(xs:string, item())*
{
    for $wanted in $wanteds
    let $date := xs:date(fn:substring-before($wanted?modified, "T"))
    where $date > $date-time
    return map {
        "title": $wanted?title,
        "modified": $date
    }
};

let $wanteds := array:flatten(fn:json-doc("merged.json"))
let $recently-updated := local:get-recently-updated-wanteds($wanteds, xs:date("2020-01-01"))
return validate {
    document {
        <wanteds count="{fn:count($recently-updated)}">
        {
            for $wanted in $recently-updated
            order by $wanted?title
            return
                <wanted title="{$wanted?title}" modified="{$wanted?modified}"/>
        }
        </wanteds>
    }
}