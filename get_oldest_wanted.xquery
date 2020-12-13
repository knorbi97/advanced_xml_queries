(: A lekérdezés eredménye egy szekvencia, amely tartalmazza azokat    :)
(: a körözés címeket amelyek a legrégebbiebbek (ha véletlen egy napon :)
(: többet is publikáltak volna).                                      :)

xquery version "3.1";

declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "text";

let $wanteds := array:flatten(fn:json-doc("merged.json"))
let $oldest-date-time := (for $wanted in $wanteds
                          return xs:dateTime($wanted?publication)) => fn:min()
return $wanteds[xs:dateTime(?publication) = $oldest-date-time]?title