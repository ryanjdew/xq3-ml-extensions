xquery version "1.0-ml";
module namespace test = "http://github.com/robwhitby/xray/test";
import module namespace assert = "http://github.com/robwhitby/xray/assertions" at "/xray/src/assertions.xqy";

import module namespace xq3 = "http://maxdewpoint.blogspot.com/xq3-ml-extensions" at "/xq3.xqy";

declare namespace html = "http://www.w3.org/1999/xhtml";

declare %test:case function innermost()
as item()*
{
  let $doc := document {
                element html:html {
                  element html:head {
                    comment {"This is a comment"},
                    element html:title {"Title"},
                    comment {"This is comment 2"}
                  },
                  element html:body {
                    element html:div {
                      attribute class {"class"}
                    }
                  }
                }
              }
  let $innermost := 
    xq3:innermost((
      $doc/html:html/html:head/html:title,
      $doc/html:html/html:head,
      $doc/html:html/html:body/html:div,
      $doc/html:html/html:body,
      $doc/html:html/html:body/html:div/@class
    ))
  return (
    assert:equal(fn:count($innermost), 2),
    assert:equal($innermost[1], $doc/html:html/html:head/html:title),
    assert:equal($innermost[2], $doc/html:html/html:body/html:div/@class)
  )
};

declare %test:case function outermost()
as item()*
{
  let $doc := document {
                element html:html {
                  element html:head {
                    comment {"This is a comment"},
                    element html:title {"Title"},
                    comment {"This is comment 2"}
                  },
                  element html:body {
                    element html:div {
                      attribute class {"class"}
                    }
                  }
                }
              }
  let $outermost := 
    xq3:outermost((
      $doc/html:html/html:head/html:title,
      $doc/html:html/html:head,
      $doc/html:html/html:body/html:div,
      $doc/html:html/html:body,
      $doc/html:html/html:body/html:div/@class
    ))
  return (
    assert:equal(fn:count($outermost), 2),
    assert:equal($outermost[1], $doc/html:html/html:head),
    assert:equal($outermost[2], $doc/html:html/html:body)
  )

};

declare %test:case function path()
as item()*
{
  let $doc := document {
                element html:html {
                  <?other-instruction do-this?>,
                  <?instruction do-this?>,
                  element html:head {
                    comment {"This is a comment"},
                    element html:title {"Title"},
                    comment {"This is comment 2"}
                  },
                  element html:body {
                    element html:div {
                      attribute class {"class"}
                    }
                  }
                }
              }
  return assert:true(
    every $node in $doc//node()/(@*|.)
    satisfies xq3:unpath(xq3:path($node), $doc) is $node
  )
};

declare  %test:case function tumbling-window()
as item()*
{
  let $windows := 
    xq3:tumbling-window(
      (: sequence :)
      (2, 4, 6, 8, 10, 12, 14),
      (: only start? :)
      fn:false(),
      (: lambda for start condition :)
      function($start) {fn:true()},
      (: only end? :)
      fn:true(),
      (: lambda for end condition :)
      function($end, $end-pos, $start, $start-pos) { $end-pos - $start-pos eq 2 },
      (: lambda for returning window :)
      function($window as item()*, $first as item(), $first-pos as xs:unsignedInt, $last as item()) {<window>{ $window }</window>}
    )
  for $start at $pos in (2, 8)
  return (
     assert:equal($start || " " || ($start + 2) || " " || ($start + 4), fn:string($windows[$pos]))
  ) 
};

declare %test:case function sliding-window()
as item()*
{
  let $windows := 
    xq3:sliding-window(
      (: sequence :)
      (2, 4, 6, 8, 10, 12, 14),
      (: only start? :)
      fn:false(),
      (: lambda for start condition :)
      function($start) {fn:true()},
      (: only end? :)
      fn:true(),
      (: lambda for end condition :)
      function($end, $end-pos, $start, $start-pos) { $end-pos - $start-pos eq 2 },
      (: lambda for returning window :)
      function($window as item()*, $first as item(), $first-pos as xs:unsignedInt, $last as item()) {<window>{ $window }</window>}
    )
  for $start at $pos in (2, 4, 6, 8, 10)
  return (
     assert:equal($start || " " || ($start + 2) || " " || ($start + 4), fn:string($windows[$pos]))
  )
};