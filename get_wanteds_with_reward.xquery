(: A lekérdezés eredménye egy XML dokumentum mely tartalmazza azon körözéseket,  :)
(: melyekért az FBI jutalmat ajánlott fel. A minimum és maximum jutalom értékek  :)
(: akkor kerülnek a dokumentumba, ha valamilyen >= 0 értékük van. Ezen körözések :)
(: száma is megjelenik a gyökérelem attribútumaként a dokumentumba.              :)

xquery version "3.1";

import schema default element namespace "" at "get_wanteds_with_reward.xsd";

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "xml";
declare option output:indent "yes";

declare function local:insert-if-greater-than-zero($tag-name as xs:string, $data as item()*) as item()*
{
    if ($data <= 0) then ()
    else element { $tag-name } { fn:format-number($data, "#,##0 $") }
};

declare function local:get-wanteds-with-reward($wanteds as item()*) as map(xs:string, item())*
{
    for $wanted in $wanteds
    return
        if (fn:empty($wanted?reward_text)) then ()
        else map {
            "title": $wanted?title,
            "reward_text": $wanted?reward_text,
            "reward_min": $wanted?reward_min,
            "reward_max": $wanted?reward_max
        }
};

let $wanteds := array:flatten(fn:json-doc("merged.json"))
let $wanteds-with-reward := local:get-wanteds-with-reward($wanteds)
return validate {
    document {
        <wanteds count="{fn:count($wanteds-with-reward)}">
        {
            for $wanted in $wanteds-with-reward
            order by $wanted?title
            return
                <wanted title="{$wanted?title}">
                    <reward_text>{$wanted?reward_text}</reward_text>
                    {local:insert-if-greater-than-zero("reward_min", $wanted?reward_min)}
                    {local:insert-if-greater-than-zero("reward_max", $wanted?reward_max)}
                </wanted>
        }
        </wanteds>
    }
}