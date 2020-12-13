(: A lekérdezés eredménye egy HTML dokumentum, melynek tartalma a feltehetőleg    :)
(: Maryland államban tartózkodó körözött személyek néhány fontosabb adata.        :)
(: Az adatok közt szerepel a körözés címe, a körözött személy általános leírása,  :)
(: a körözött személy külső leírását tartalmazó táblázat és végül az FBI oldalára :)
(: mutató link ahol megtalálható a pontosabb leírás és az adott körözéshez        :)
(: kapcsolódó egyéb körözések. Az adatok közt található HTML elemek parse-olását  :)
(: SAXON segítségével végzi el a lekérdezés.                                      :)

xquery version "3.1";

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html";
declare option output:html-version "5.0";
declare option output:indent "yes";
declare option output:encoding "UTF-8";

declare function local:parse-html-if-not-empty($title as xs:string, $html as xs:string*) as item()*
{
    if (fn:empty($html)) then ()
    else
        <div>
            <h5>{$title}</h5>
            {saxon:parse-html($html)//*[name() = "p"]}
        </div>
};

declare function local:insert-row-if-not-empty($title as xs:string, $data as item()*) as item()*
{
    if (fn:empty($data)) then ()
    else
        <tr>
            <td>{$title}</td>
            <td>{$data}</td>
        </tr>
};

let $wanteds := array:flatten(fn:json-doc("merged.json"))
return
    document {
        <html>
            <head>
                <title>Wanted - possibly in Maryland</title>
                <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta1/dist/css/bootstrap.min.css" rel="stylesheet"/>
            </head>
            <body>
            {
                for $uid in fn:unparsed-text-lines("uids.txt")
                where fn:not(fn:starts-with($uid, "#"))
                let $wanted := $wanteds[?uid = $uid]
                count $count
                return
                    <div>
                        {if ($count = 1) then () else <hr/>}
                        <h3 class="text-center">{$wanted?title}</h3>
                            <div class="text-center">
                            {
                              for $image in array:flatten($wanted?images)
                              return
                                  <img class="mx-3 rounded float-left border border-dark" src="{$image?thumb}"/>
                            }
                            </div>
                            {
                              if (fn:empty($wanted?description)) then ()
                              else 
                                  <div>
                                      <h5>Description</h5>
                                      <p>{$wanted?description}</p>
                                  </div>
                             }
                            {local:parse-html-if-not-empty("Details", $wanted?details)}
                            <table class="table table-striped">
                                <tbody>
                                    {local:insert-row-if-not-empty("Hair", $wanted?hair_raw)}
                                    {local:insert-row-if-not-empty("Eyes", $wanted?eyes_raw)}
                                    {local:insert-row-if-not-empty("Height", $wanted?height)}
                                    {local:insert-row-if-not-empty("Weight", $wanted?weight)}
                                    {local:insert-row-if-not-empty("Sex", $wanted?sex)}
                                    {local:insert-row-if-not-empty("Race", $wanted?race)}
                                    {local:insert-row-if-not-empty("Occupation", $wanted?occupations)}
                                </tbody>
                            </table>
                            {local:parse-html-if-not-empty("Caution", $wanted?caution)}
                            <a href="{$wanted?url}">Information about person on FBI's website</a>
                    </div>
            }
            </body>
        </html>
    }