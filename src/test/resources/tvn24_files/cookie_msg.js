// zewnetrzna konfiguracja popup rodo
//  rodo_config_cms - getRodo.php
//  rodoConfiguration = {
//         show: true, // typ boolean - czy rodo sie pokazuje
//         waitingTime: 30, // (podajemy w sekundach) - czas po jakim przy zamknieciu rodo(przypomnij później) uruchomi się ponownie okno rodo
//         comapny: 'tvn' // string, nazwa spółki, dla której klauzulę chcemy wyświetlić
//         displayRemindMeLaterButton: true // boolean, decyduje czy przycisk "Przypomnij mi później" ma być widoczny
//         privatePolicyUrl: undefined // string, umozliwia zdefiniowanie własnego url do polityki prywatnosci
//         callback: function(){}
//     }
// cookie_msg_options = {
//     texts: {
//         en: {
//             policy_href: '/politykaprywatnosci?lang=en&privacyId=tvn_privacy'
//         }
//     }
// }
//
// function dynamicallyLoadScript(url) {
//     var script = document.createElement("script");
//     script.id = 'cookie_script';
//     script.src = url;
//     document.head.appendChild(script);
// }
// dynamicallyLoadScript('https://statictvn.beta-test.online.tvwisla.com.pl/cookie/cookie_msg.js?lang=en');
//
var RODO_ACCEPTED = 'rodo_accepted',
    RODO_X_BUTTON = 'rodo_x_button',
    RODO_REMIND_LATER = 'rodo_remind_later',
    RODO_ADO_CODE = {
        clause_tvn: 1,
        clause_ttv: 2
    },
    rodo_config_cms = {};

var RESTRICTED_RODO_DOMAINS = ["distribution.tvn.pl"];

function setCookie(cookieName, value, exdays) {
    var exdate = new Date();
    exdate.setDate(exdate.getDate() + exdays);
    var c_value = escape(value) + ((exdays == null) ? "" : "; expires=" + exdate.toUTCString());
    document.cookie = cookieName + "=" + c_value;

}

function getMainDomain() {
    var hostname = window.location.hostname,
        hostnamePartsCount = hostname.split('.').length;
    return (hostnamePartsCount > 2 && RESTRICTED_RODO_DOMAINS.indexOf(hostname) === -1) ? hostname.substr(hostname.indexOf('.')) : hostname;
}

function setCookieRodo(cookieName, value, time) {
    var date = new Date();
    date.setTime(date.getTime() + (time * 1000));

    var c_value = (value) + ((time == null) ? "" : "; expires=" + date.toUTCString());
    var domain = getMainDomain();
    document.cookie = cookieName + "=" + c_value + "; domain=" + domain + "; path=/";
}

function getCookie(c_name) {
    var i, x, y, ARRcookies = document.cookie.split(";");
    for (i = 0; i < ARRcookies.length; i++) {
        x = ARRcookies[i].substr(0, ARRcookies[i].indexOf("="));
        y = ARRcookies[i].substr(ARRcookies[i].indexOf("=") + 1);
        x = x.replace(/^\s+|\s+$/g, "");
        if (x == c_name) {
            return unescape(y);
        }
    }
    return false;
}

$(function () {
    function getHost() {
        var srcCookieFile = 'cookie/cookie_msg.js';
        if ($("script[src*='" + srcCookieFile + "']").length) {
            var element = $("script[src*='" + srcCookieFile + "']").attr("src");

            indexStart = element.search(srcCookieFile);
            element = element.substring(0, indexStart);
        }

        return element ? element : '';
    }

    var clickCloseRodo = false,
        lang = "pl",
        target = document.getElementById('cookie_script');

    if (target !== undefined && target !== null && target.src !== undefined && (target.src).indexOf("?")) {
        var urlArray;
        urlArray = (target.src).split("?");

        if (urlArray[1] !== undefined && urlArray[1].indexOf("en")) {
            lang = "en";
        }
    }

    var _options = {
        id: 'msgLayer',
        cookie: 'cookieMsg',
        css: {
            main: {
                width: '100%',
                position: 'fixed',
                bottom: 0,
                background: '#00a6ff',
                opacity: '.93',
                '-ms-filter': 'progid:DXImageTransform.Microsoft.Alpha(Opacity=93)',
                color: 'white',
                zIndex: 2000,
                fontSize: '12px',
                fontFamily: 'Arial',
                fontWeight: 'normal'
            },
            box: {
                margin: '0 auto',
                'max-width': '968px'
            },
            close: {
                float: 'right',
                cursor: 'pointer',
                height: '50px',
                paddingRight: '5px',
                fontFamily: 'Arial',
                lineHeight: 'normal',
                'z-index': '100'
            },
            container: {
                margin: '14px',
                lineHeight: 'normal',
                letterSpacing: 'normal'
            },
            header: {
                fontSize: '14px',
                marginBottom: '10px',
                fontFamily: 'Arial',
                color: '#ffffff',
                fontWeight: 'normal',
                letterSpacing: 'normal',
                lineHeight: 'normal',
                padding: 0
            },
            content: {
                fontFamily: 'Arial',
                fontSize: '12px'
            }
        },
        texts: {
            pl: {
                close: "zamknij X",
                header: "Powiadomienie o plikach cookie",
                content: "Strona korzysta z plików cookies i innych technologii automatycznego przechowywania danych do celów statystycznych, realizacji usług i reklamowych. Korzystając z naszych stron bez zmiany ustawień przeglądarki będą one zapisane w pamięci urządzenia, więcej informacji na temat zarządzania plikami cookies znajdziesz w <a class=\"privacy-policy-link\" target=\"_blank\" style=\"color: #fff; text-decoration: underline;\">Polityce prywatności</a>.",
                policy_href: "http://s.tvn.pl/pdf/polityka_prywatnosci.pdf"
            },
            en: {
                close: "close X",
                header: "Cookies Policy",
                content: "The site uses cookies and other technologies used to automatically store data for the purposes of statistics, service provision and advertising. When you use our websites without changing the settings of your browser, cookies will be stored on your device. For more information on managing cookies, see the <a class=\"privacy-policy-link\" target=\"_blank\" style=\"color: #fff; text-decoration: underline;\">Privacy Policy</a>.",
                policy_href: "http://s.tvn.pl/pdf/privacy_policy.pdf"
            }
        }
    };


    var _rodoOptions = {
        show: true,
        waitingTime: 60,
        company: 'tvn',
        rodoId: 'clause_tvn',
        lang: 'pl',
        displayRemindMeLaterButton: true,
        privatePolicyUrl: undefined,
        callback: function () {
        }
    };

    function loadRodoPopup() {
        $('body').append($("<div>").attr('id', 'rodoLayer'));
        var $rodoLayer = $('#rodoLayer'),
            url = getHost() + "cookie/getRodo.php?lang=" + rodoOptions.lang +
                '&rodoId=' + rodoOptions.rodoId +
                "&displayRemindMeLaterButton=" + (+rodoOptions.displayRemindMeLaterButton);
        // url = getHost() + "cookie/rodo.php?company=" + rodoOptions.company +
        //     "&displayRemindMeLaterButton=" + (+rodoOptions.displayRemindMeLaterButton);
        if (getHost() !== '') {
            $rodoLayer.load(url, function () {
                initRodo();
            });
        }
    }

    var options = $.extend(true, _options, typeof cookie_msg_options != 'undefined' ? cookie_msg_options : {}),
        rodoOptions = $.extend(true, _rodoOptions, typeof rodoConfiguration != 'undefined' ? rodoConfiguration : {}),
        flag = getCookie(options['cookie']),
        flagRodo = getCookie('rodoWindowPolicy');

    loadRodoPopup();

    function addHrefAttributePrivatePolicy() {
        var $privatePolicyLinks = $("#rodoLayer .rodoLinkPrivatePolicy"),
            company, link;

        if ($privatePolicyLinks.length) {
            if (rodoOptions.privatePolicyUrl) {
                link = rodoOptions.privatePolicyUrl;
            } else {
                company = rodoOptions.company !== 'tvn' ? '_' + rodoOptions.company : '';
                link = getHost() + 'pdf/polityka_prywatnosci' + company + '.pdf'
            }

            $privatePolicyLinks.attr('href', link);
        }
    }

    function addHrefAttributePrivatePolicySite() {
        if ($("#rodoLayer .rodoLinkPrivatePolicySite").length) {
            // var host = getHost().replace(/(^\/\/|^https:\/\/)/, 'http://');
            var href = $("#rodoLayer .rodoLinkPrivatePolicySite").attr('href').replace(/(^\/\/|^https:\/\/)/, 'http://');
            // $("#rodoLayer .rodoLinkPrivatePolicySite").attr('href', host + 'politykaprywatnosci/');
            $("#rodoLayer .rodoLinkPrivatePolicySite").attr('href', href);
        }
    }

    function addHrefAttributePartners() {
        if ($("#rodoLayer .rodoLinkPartners").length) {
            $("#rodoLayer .rodoLinkPartners").attr('href', getHost() + 'pdf/zaufani_partnerzy.pdf');
        }
    }

    function btnClickAcceptPolicyRodo() {
        $('#rodoLayer').find('.rodoFooterBtnAccept, .rodoHeaderBtnClose').click(function (e) {
            e.preventDefault();

            var action = $(this).hasClass('rodoHeaderBtnClose') ? RODO_X_BUTTON : RODO_ACCEPTED;

            clickCloseRodo = true;
            if (clickCloseRodo) {
                setCookieRodo('rodoWindowPolicy', 'true', 31536000); // 365 dni
                getLinkGemius();
                statsHit(action);
                $(this).parent().parent().parent().remove();
            }
        });
    }

    function getLinkGemius() {
        var adoCode = RODO_ADO_CODE.hasOwnProperty(rodoOptions.rodoId) ? RODO_ADO_CODE[rodoOptions.rodoId] : RODO_ADO_CODE.clause_tvn;
        if (rodo_config_cms && rodo_config_cms.hasOwnProperty('ADO_ID')) {
            adoCode = rodo_config_cms.ADO_ID;
        }
        $("body").append($("<img>").attr(
            "src",
            "https://tvn.adocean.pl/adredir/id=LRBKcKOc84ybgnL2.wgfrVpvj.Q7jpCpAK7fvgOCP8b.N7/aocodetype=1/ADD_rodo=" + adoCode + "/url=//tvn.hit.gemius.pl/redot.gif"
        ));
    }

    function btnClickClosePolicyRodo() {
        $('#rodoLayer').find('.rodoFooterBtnRemindMeLater').click(function (e) {
            e.preventDefault();

            var date = new Date(Date.now() + rodoOptions.waitingTime / 0.001),
                time = Math.floor(date.getTime());

            statsHit(RODO_REMIND_LATER);
            setCookieRodo('rodoWindowRemindLater', time, rodoOptions.waitingTime);

            $(this).parent().parent().parent().remove();
        });
    }

    function btnSeeMore() {
        if ($('#rodoLayer .rodoContentLinkMore').length) {
            $('#rodoLayer .rodoContentLinkMore').click(function (e) {
                e.preventDefault();

                $('#rodoLayer .rodoContentAll').css('display', 'block');
                $(this).css('display', 'none');
            });
        }
    }

    function initRodo() {
        var flag = getCookie(options['cookie']),
            flagRodoRemindLater = getCookie('rodoWindowRemindLater'),
            checkRemindLater = !flagRodoRemindLater || (Date.now() - flagRodoRemindLater) >= rodoOptions.waitingTime;

        if (rodoOptions.show && !flagRodo && checkRemindLater) {
            if ($('#rodoLayer').length) {
                addHrefAttributePrivatePolicy();
                addHrefAttributePrivatePolicySite();
                addHrefAttributePartners();
                btnClickClosePolicyRodo();
                $('#rodoLayer').css('display', 'block');
                statsHit();
                btnClickAcceptPolicyRodo();
                btnSeeMore();
            }
        }
    }

    function statsHit(action) {
        var gemiusId,
            pixEvent,
            ownerParam;

        if (typeof action !== 'undefined') {
            switch (action) {
                case RODO_ACCEPTED:
                    gemiusId = 'nd1KVnMjj1LXyZ2qSvY59fU3HbGF.mO2Acn8MPVA9y..X7';
                    pixEvent = "przejdź_do_serwisu";
                    break;
                case RODO_X_BUTTON:
                    gemiusId = '.RdAVGMUswFt3XwfnKZAmfTXHSeFDmOah9.cVBzEj8P.p7';
                    pixEvent = "klikniecie_x";
                    break;
                case RODO_REMIND_LATER:
                    gemiusId = 'p81AV.t4swDRTHwfBmLIAtWZfVC1SyLYh2AcovzeN9L.U7';
                    pixEvent = "przypomnij_pozniej";
                default:
            }
        } else {
            gemiusId = 'ndzq9nMjfxudslMXvCKFaKe13yiIl3sebJc1Z2SK_Zj.n7';
            pixEvent = "wyswietlenie_planszy";
        }

        pp_gemius_extraparameters = typeof pp_gemius_extraparameters !== 'undefined' ? pp_gemius_extraparameters : [];
        var owner = 'tvn_sa_pl';
        if (rodo_config_cms && rodo_config_cms.hasOwnProperty('GEMIUS_AND_PIX_OWNER_PARAMETER')) {
            owner = rodo_config_cms.GEMIUS_AND_PIX_OWNER_PARAMETER;
        }
        ownerParam = 'owner=' + owner;

        // dodajemy parametr id_p jeśli to konieczne
        if (typeof __pix2 !== 'undefined' && typeof __pix2.getUUID === 'function' && noIdPParameter()) {
            pp_gemius_extraparameters.push('id_p=' + __pix2.getUUID());
        }

        if (typeof gemius_event !== "undefined") {
            try {
                pp_gemius_extraparameters.unshift(gemiusId);
                gemius_event.apply(undefined, prapereGemiusParams(pp_gemius_extraparameters, ownerParam));
                pp_gemius_extraparameters.shift(gemiusId);
            } catch (e) {
            }
        }

        if (typeof __pix2 !== "undefined") {
            // nie chcemy parametrów at i ob dla rodo, nie możemy pozwolić na ich przekazanie przez __pix2.event()
            if (typeof getAdditionalParamsPix2 === 'function') {
                var getAdditionalParamsPix2Copy = getAdditionalParamsPix2;
            }

            getAdditionalParamsPix2 = function () {
                return {
                    'ap': ownerParam
                }
            };

            __pix2.event(pixEvent);

            // serwis macierzysty może chcieć dalej wykonywać hity pixowe, musi wiec posiadac informacje o at i ob
            if (typeof getAdditionalParamsPix2Copy === 'function') {
                getAdditionalParamsPix2 = getAdditionalParamsPix2Copy;
            }
        }
    }

    if (!flag) {
        $("body").append(
            $('<div>').attr('id', options.id).css(options['css']['main'])
                .append($('<div>').css(options['css']['box'])
                    .append($('<div>').css(options['css']['close']).html(options['texts'][lang]['close']).click(function () {
                        setCookie(options['cookie'], 'set', 365);
                        $(this).parent().remove();
                    }))
                    .append($('<div>').addClass('container').css(options['css']['container'])
                        .append($('<h3>').css(options['css']['header']).html(options['texts'][lang]['header']))
                        .append($('<div>').css(options['css']['content']).html(options['texts'][lang]['content']))
                    )
                )
        );
        $('.privacy-policy-link').attr('href', options['texts'][lang]['policy_href']);
    } else {
        setCookie(options['cookie'], 'set', 365);
    }

    function noIdPParameter() {
        for (var i = 0; i < pp_gemius_extraparameters.length; i++) {
            if (pp_gemius_extraparameters[i].indexOf('id_p=') !== -1) {
                return false;
            }
        }

        return true;
    }

    function prapereGemiusParams(gemiusParams, ownerParam) {
        var params = [],
            i;

        for (i = 0; i < gemiusParams.length; i++) {
            if (gemiusParams[i].indexOf('at=') === -1 && gemiusParams[i].indexOf('ob=') === -1) {
                params.push(gemiusParams[i]);
            }
        }

        params.push(ownerParam);

        return params;
    }

});
