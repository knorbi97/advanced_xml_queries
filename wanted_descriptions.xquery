(: A lekérdezés eredménye egy XML dokumentum mely tartalmazza azon körözött személyek       :)
(: személyes ismertetőjegyeit, de csak azokat a személyeket választja ki, ahol legalább     :)
(: egy ismeretetőjegy jelen van. Ezen körözött személyek száma a gyökérelem attribútumaként :)
(: megtalálható a dokumentumba.                                                             :)

xquery version "3.1";

import schema default element namespace "" at "wanted_descriptions_schema.xsd";

declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "xml";
declare option output:indent "yes";

declare function local:insert-if-not-empty($tag-name as xs:string, $data as item()*) as item()*
{
    if (fn:empty($data) or $data = "" or $data = "Unknown" or $data = "None known") then ()
    else element { $tag-name } { $data }
};

declare function local:get-wanteds($wanteds as item()*) as item()*
{
    for $wanted in $wanteds
    return
      <wanted title="{$wanted?title}">
          {local:insert-if-not-empty("eyes", $wanted?eyes)}
          {local:insert-if-not-empty("hair", $wanted?hair)}
          {local:insert-if-not-empty("height", $wanted?height)}
          {local:insert-if-not-empty("weight", $wanted?weight)}
          {local:insert-if-not-empty("scars_and_marks", $wanted?scars_and_marks)}
      </wanted>
};

declare function local:get-non-empty-wanteds($wanteds as item()*) as item()*
{
    for $node in local:get-wanteds($wanteds)
    return
        if (fn:has-children($node)) then $node
        else ()
};

let $wanteds := array:flatten(fn:json-doc("merged.json"))
let $non-empty-wanteds := local:get-non-empty-wanteds($wanteds)
return validate {
    document {
        <wanteds count="{fn:count($non-empty-wanteds)}">
        {
            $non-empty-wanteds
        }
        </wanteds>
    }
}