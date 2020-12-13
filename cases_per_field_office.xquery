(: A lekérdezés eredménye egy XML dokumentum mely tartalmazza az egyes     :)
(: területi irodákhoz (field office) kapcsolódó körözött személyek számát, :)
(: továbbá az irodákhoz tartozó körözött személyeket mint gyermekelem.     :)
(: Az irodák nevei és a körözött személyekhez tartozó címek lexikografikus :)
(: sorrendben kerülnek a dokumentumba. Az irodák száma a gyökérelem        :)
(: attribútumaként megtalálható a dokumentumba.                            :)

xquery version "3.1";

import schema default element namespace "" at "cases_per_field_office.xsd";

declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "xml";
declare option output:indent "yes";

declare function local:get-field-offices($wanteds as item()*) as item()*
{
    fn:distinct-values(for $wanted in $wanteds
                       return $wanted?field_offices) => fn:sort()
};

declare function local:get-cases($wanteds as item()*, $offices as item()*) as item()*
{
    for $office in $offices
    return
        for $wanted in $wanteds
        where fn:not(fn:empty($wanted?field_offices[. = $office]))
        return $wanted?title
};

let $wanteds := array:flatten(fn:json-doc("merged.json"))
let $offices := local:get-field-offices($wanteds)
return validate {
    document {
        <offices count="{fn:count($offices)}">
        {
            for $office in $offices
            let $cases := local:get-cases($wanteds, $office)
            return
                <office name="{$office}" case-count="{fn:count($cases)}">
                {
                    for $case in $cases
                    order by $case
                    return
                        <wanted title="{$case}"/>
                }
                </office>
        }
        </offices>
    }
}