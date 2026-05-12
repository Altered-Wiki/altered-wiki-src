-- Module:LegalStatus
-- Renders a color-coded legal status table + choropleth map for substance articles.
-- Usage in articles:
--   {{#invoke:LegalStatus|render | de=grey | de_note=NpSG grey area | ru=unscheduled }}

local p = {}

-- Maps lowercase ISO 3166-1 alpha-2 param name → { display name, flag emoji, GeoJSON ISO key }
-- The GeoJSON ISO key matches what geojson_to_lua.py writes into Module:CountryGeoJSON.
local COUNTRIES = {
    af = { "Afghanistan",            "🇦🇫", "AF" },
    al = { "Albania",                "🇦🇱", "AL" },
    dz = { "Algeria",                "🇩🇿", "DZ" },
    ad = { "Andorra",                "🇦🇩", "AD" },
    ao = { "Angola",                 "🇦🇴", "AO" },
    ar = { "Argentina",              "🇦🇷", "AR" },
    am = { "Armenia",                "🇦🇲", "AM" },
    au = { "Australia",              "🇦🇺", "AU" },
    at = { "Austria",                "🇦🇹", "AT" },
    az = { "Azerbaijan",             "🇦🇿", "AZ" },
    bs = { "Bahamas",                "🇧🇸", "BS" },
    bh = { "Bahrain",                "🇧🇭", "BH" },
    bd = { "Bangladesh",             "🇧🇩", "BD" },
    bb = { "Barbados",               "🇧🇧", "BB" },
    by = { "Belarus",                "🇧🇾", "BY" },
    be = { "Belgium",                "🇧🇪", "BE" },
    bz = { "Belize",                 "🇧🇿", "BZ" },
    bj = { "Benin",                  "🇧🇯", "BJ" },
    bt = { "Bhutan",                 "🇧🇹", "BT" },
    bo = { "Bolivia",                "🇧🇴", "BO" },
    ba = { "Bosnia and Herzegovina", "🇧🇦", "BA" },
    bw = { "Botswana",               "🇧🇼", "BW" },
    br = { "Brazil",                 "🇧🇷", "BR" },
    bn = { "Brunei",                 "🇧🇳", "BN" },
    bg = { "Bulgaria",               "🇧🇬", "BG" },
    bf = { "Burkina Faso",           "🇧🇫", "BF" },
    bi = { "Burundi",                "🇧🇮", "BI" },
    cv = { "Cabo Verde",             "🇨🇻", "CV" },
    kh = { "Cambodia",               "🇰🇭", "KH" },
    cm = { "Cameroon",               "🇨🇲", "CM" },
    ca = { "Canada",                 "🇨🇦", "CA" },
    cf = { "Central African Republic","🇨🇫","CF" },
    td = { "Chad",                   "🇹🇩", "TD" },
    cl = { "Chile",                  "🇨🇱", "CL" },
    cn = { "China",                  "🇨🇳", "CN" },
    co = { "Colombia",               "🇨🇴", "CO" },
    km = { "Comoros",                "🇰🇲", "KM" },
    cg = { "Republic of the Congo",  "🇨🇬", "CG" },
    cd = { "DR Congo",               "🇨🇩", "CD" },
    cr = { "Costa Rica",             "🇨🇷", "CR" },
    hr = { "Croatia",                "🇭🇷", "HR" },
    cu = { "Cuba",                   "🇨🇺", "CU" },
    cy = { "Cyprus",                 "🇨🇾", "CY" },
    cz = { "Czech Republic",         "🇨🇿", "CZ" },
    dk = { "Denmark",                "🇩🇰", "DK" },
    dj = { "Djibouti",               "🇩🇯", "DJ" },
    ["do"] = { "Dominican Republic", "🇩🇴", "DO" },
    ec = { "Ecuador",                "🇪🇨", "EC" },
    eg = { "Egypt",                  "🇪🇬", "EG" },
    sv = { "El Salvador",            "🇸🇻", "SV" },
    gq = { "Equatorial Guinea",      "🇬🇶", "GQ" },
    er = { "Eritrea",                "🇪🇷", "ER" },
    ee = { "Estonia",                "🇪🇪", "EE" },
    sz = { "Eswatini",               "🇸🇿", "SZ" },
    et = { "Ethiopia",               "🇪🇹", "ET" },
    fj = { "Fiji",                   "🇫🇯", "FJ" },
    fi = { "Finland",                "🇫🇮", "FI" },
    fr = { "France",                 "🇫🇷", "FR" },
    ga = { "Gabon",                  "🇬🇦", "GA" },
    gm = { "Gambia",                 "🇬🇲", "GM" },
    ge = { "Georgia",                "🇬🇪", "GE" },
    de = { "Germany",                "🇩🇪", "DE" },
    gh = { "Ghana",                  "🇬🇭", "GH" },
    gr = { "Greece",                 "🇬🇷", "GR" },
    gd = { "Grenada",                "🇬🇩", "GD" },
    gt = { "Guatemala",              "🇬🇹", "GT" },
    gn = { "Guinea",                 "🇬🇳", "GN" },
    gw = { "Guinea-Bissau",          "🇬🇼", "GW" },
    gy = { "Guyana",                 "🇬🇾", "GY" },
    ht = { "Haiti",                  "🇭🇹", "HT" },
    hn = { "Honduras",               "🇭🇳", "HN" },
    hu = { "Hungary",                "🇭🇺", "HU" },
    is = { "Iceland",                "🇮🇸", "IS" },
    ["in"] = { "India",              "🇮🇳", "IN" },
    id = { "Indonesia",              "🇮🇩", "ID" },
    ir = { "Iran",                   "🇮🇷", "IR" },
    iq = { "Iraq",                   "🇮🇶", "IQ" },
    ie = { "Ireland",                "🇮🇪", "IE" },
    il = { "Israel",                 "🇮🇱", "IL" },
    it = { "Italy",                  "🇮🇹", "IT" },
    jm = { "Jamaica",                "🇯🇲", "JM" },
    jp = { "Japan",                  "🇯🇵", "JP" },
    jo = { "Jordan",                 "🇯🇴", "JO" },
    kz = { "Kazakhstan",             "🇰🇿", "KZ" },
    ke = { "Kenya",                  "🇰🇪", "KE" },
    ki = { "Kiribati",               "🇰🇮", "KI" },
    kp = { "North Korea",            "🇰🇵", "KP" },
    kr = { "South Korea",            "🇰🇷", "KR" },
    kw = { "Kuwait",                 "🇰🇼", "KW" },
    kg = { "Kyrgyzstan",             "🇰🇬", "KG" },
    la = { "Laos",                   "🇱🇦", "LA" },
    lv = { "Latvia",                 "🇱🇻", "LV" },
    lb = { "Lebanon",                "🇱🇧", "LB" },
    ls = { "Lesotho",                "🇱🇸", "LS" },
    lr = { "Liberia",                "🇱🇷", "LR" },
    ly = { "Libya",                  "🇱🇾", "LY" },
    li = { "Liechtenstein",          "🇱🇮", "LI" },
    lt = { "Lithuania",              "🇱🇹", "LT" },
    lu = { "Luxembourg",             "🇱🇺", "LU" },
    mg = { "Madagascar",             "🇲🇬", "MG" },
    mw = { "Malawi",                 "🇲🇼", "MW" },
    my = { "Malaysia",               "🇲🇾", "MY" },
    mv = { "Maldives",               "🇲🇻", "MV" },
    ml = { "Mali",                   "🇲🇱", "ML" },
    mt = { "Malta",                  "🇲🇹", "MT" },
    mr = { "Mauritania",             "🇲🇷", "MR" },
    mu = { "Mauritius",              "🇲🇺", "MU" },
    mx = { "Mexico",                 "🇲🇽", "MX" },
    fm = { "Micronesia",             "🇫🇲", "FM" },
    md = { "Moldova",                "🇲🇩", "MD" },
    mc = { "Monaco",                 "🇲🇨", "MC" },
    mn = { "Mongolia",               "🇲🇳", "MN" },
    me = { "Montenegro",             "🇲🇪", "ME" },
    ma = { "Morocco",                "🇲🇦", "MA" },
    mz = { "Mozambique",             "🇲🇿", "MZ" },
    mm = { "Myanmar",                "🇲🇲", "MM" },
    na = { "Namibia",                "🇳🇦", "NA" },
    nr = { "Nauru",                  "🇳🇷", "NR" },
    np = { "Nepal",                  "🇳🇵", "NP" },
    nl = { "Netherlands",            "🇳🇱", "NL" },
    nz = { "New Zealand",            "🇳🇿", "NZ" },
    ni = { "Nicaragua",              "🇳🇮", "NI" },
    ne = { "Niger",                  "🇳🇪", "NE" },
    ng = { "Nigeria",                "🇳🇬", "NG" },
    mk = { "North Macedonia",        "🇲🇰", "MK" },
    no = { "Norway",                 "🇳🇴", "NO" },
    om = { "Oman",                   "🇴🇲", "OM" },
    pk = { "Pakistan",               "🇵🇰", "PK" },
    pw = { "Palau",                  "🇵🇼", "PW" },
    pa = { "Panama",                 "🇵🇦", "PA" },
    pg = { "Papua New Guinea",       "🇵🇬", "PG" },
    py = { "Paraguay",               "🇵🇾", "PY" },
    pe = { "Peru",                   "🇵🇪", "PE" },
    ph = { "Philippines",            "🇵🇭", "PH" },
    pl = { "Poland",                 "🇵🇱", "PL" },
    pt = { "Portugal",               "🇵🇹", "PT" },
    qa = { "Qatar",                  "🇶🇦", "QA" },
    ro = { "Romania",                "🇷🇴", "RO" },
    ru = { "Russia",                 "🇷🇺", "RU" },
    rw = { "Rwanda",                 "🇷🇼", "RW" },
    kn = { "Saint Kitts and Nevis",  "🇰🇳", "KN" },
    lc = { "Saint Lucia",            "🇱🇨", "LC" },
    vc = { "Saint Vincent",          "🇻🇨", "VC" },
    ws = { "Samoa",                  "🇼🇸", "WS" },
    sm = { "San Marino",             "🇸🇲", "SM" },
    st = { "São Tomé and Príncipe",  "🇸🇹", "ST" },
    sa = { "Saudi Arabia",           "🇸🇦", "SA" },
    sn = { "Senegal",                "🇸🇳", "SN" },
    rs = { "Serbia",                 "🇷🇸", "RS" },
    sc = { "Seychelles",             "🇸🇨", "SC" },
    sl = { "Sierra Leone",           "🇸🇱", "SL" },
    sg = { "Singapore",              "🇸🇬", "SG" },
    sk = { "Slovakia",               "🇸🇰", "SK" },
    si = { "Slovenia",               "🇸🇮", "SI" },
    sb = { "Solomon Islands",        "🇸🇧", "SB" },
    so = { "Somalia",                "🇸🇴", "SO" },
    za = { "South Africa",           "🇿🇦", "ZA" },
    ss = { "South Sudan",            "🇸🇸", "SS" },
    es = { "Spain",                  "🇪🇸", "ES" },
    lk = { "Sri Lanka",              "🇱🇰", "LK" },
    sd = { "Sudan",                  "🇸🇩", "SD" },
    sr = { "Suriname",               "🇸🇷", "SR" },
    se = { "Sweden",                 "🇸🇪", "SE" },
    ch = { "Switzerland",            "🇨🇭", "CH" },
    sy = { "Syria",                  "🇸🇾", "SY" },
    tw = { "Taiwan",                 "🇹🇼", "TW" },
    tj = { "Tajikistan",             "🇹🇯", "TJ" },
    tz = { "Tanzania",               "🇹🇿", "TZ" },
    th = { "Thailand",               "🇹🇭", "TH" },
    tl = { "Timor-Leste",            "🇹🇱", "TL" },
    tg = { "Togo",                   "🇹🇬", "TG" },
    to = { "Tonga",                  "🇹🇴", "TO" },
    tt = { "Trinidad and Tobago",    "🇹🇹", "TT" },
    tn = { "Tunisia",                "🇹🇳", "TN" },
    tr = { "Turkey",                 "🇹🇷", "TR" },
    tm = { "Turkmenistan",           "🇹🇲", "TM" },
    tv = { "Tuvalu",                 "🇹🇻", "TV" },
    ug = { "Uganda",                 "🇺🇬", "UG" },
    ua = { "Ukraine",                "🇺🇦", "UA" },
    ae = { "United Arab Emirates",   "🇦🇪", "AE" },
    uk = { "United Kingdom",         "🇬🇧", "GB" },
    us = { "United States",          "🇺🇸", "US" },
    uy = { "Uruguay",                "🇺🇾", "UY" },
    uz = { "Uzbekistan",             "🇺🇿", "UZ" },
    vu = { "Vanuatu",                "🇻🇺", "VU" },
    ve = { "Venezuela",              "🇻🇪", "VE" },
    vn = { "Vietnam",                "🇻🇳", "VN" },
    ye = { "Yemen",                  "🇾🇪", "YE" },
    zm = { "Zambia",                 "🇿🇲", "ZM" },
    zw = { "Zimbabwe",               "🇿🇼", "ZW" },
}

local STATUS_LABEL = {
    unscheduled  = "Unscheduled",
    scheduled    = "Scheduled",
    grey         = "Grey area",
    prescription = "Prescription only",
    unknown      = "Unknown",
}

local STATUS_CSS = {
    unscheduled  = "unscheduled",
    scheduled    = "scheduled",
    grey         = "grey",
    prescription = "prescription",
    unknown      = "unknown",
}

-- Fill colors match the CSS badge palette (common-css.css)
local STATUS_FILL = {
    unscheduled  = "#28a745",
    scheduled    = "#dc3545",
    grey         = "#e6a817",
    prescription = "#0d6efd",
    unknown      = "#adb5bd",
}

local function parseArgs(args)
    local result = {}
    for k, v in pairs(args) do
        k = mw.text.trim(tostring(k))
        v = mw.text.trim(tostring(v))
        if COUNTRIES[k] and v ~= "" and not k:find("_note$") then
            table.insert(result, {
                code   = k,
                status = v,
                note   = mw.text.trim(args[k .. "_note"] or ""),
                meta   = COUNTRIES[k],
            })
        end
    end
    table.sort(result, function(a, b) return a.meta[1] < b.meta[1] end)
    return result
end

local function buildTable(countries)
    local t = mw.html.create("table"):addClass("legal-status-table")
    for _, c in ipairs(countries) do
        local label  = STATUS_LABEL[c.status]  or "Unknown"
        local css    = STATUS_CSS[c.status]    or "unknown"
        local tr = t:tag("tr")
        tr:tag("td"):addClass("legal-status-table__country")
          :wikitext(c.meta[2] .. "\194\160" .. c.meta[1])
        tr:tag("td")
          :wikitext('<span class="legal-status-badge legal-status-badge--' .. css .. '">'
                    .. label .. '</span>')
        tr:tag("td"):addClass("legal-status-table__note"):wikitext(c.note)
    end
    return tostring(t)
end

local function ringToPoints(ring)
    local pts = {}
    for _, pt in ipairs(ring) do
        -- GeoJSON stores [lon, lat]; Maps polygons= expects "lat,lon"
        table.insert(pts, tostring(pt[2]) .. "," .. tostring(pt[1]))
    end
    return table.concat(pts, ":")
end

local function buildMap(frame, countries)
    local ok, geoData = pcall(mw.loadData, "Module:CountryGeoJSON")
    if not ok then return "" end

    local polys = {}
    for _, c in ipairs(countries) do
        local iso  = c.meta[3]
        local geo  = geoData[iso]
        if geo then
            local fill  = STATUS_FILL[c.status]  or STATUS_FILL.unknown
            local label = STATUS_LABEL[c.status] or "Unknown"
            -- polygons= style suffix: ~Title~Desc~BorderColor~BorderOpacity~BorderWidth~FillColor~FillOpacity
            local style = "~" .. c.meta[1] .. "~" .. label
                       .. "~#555555~0.8~1~" .. fill .. "~0.65"
            if geo.t == "Polygon" then
                local pts = ringToPoints(geo.c[1])
                if pts ~= "" then table.insert(polys, pts .. style) end
            elseif geo.t == "MultiPolygon" then
                for _, polygon in ipairs(geo.c) do
                    local pts = ringToPoints(polygon[1])
                    if pts ~= "" then table.insert(polys, pts .. style) end
                end
            end
        end
    end

    if #polys == 0 then return "" end

    return frame:callParserFunction("#display_map", {
        "",
        polygons = table.concat(polys, ";"),
        width    = "100%",
        height   = "260",
        zoom     = "1",
    })
end

function p.render(frame)
    local args = frame.args
    local countries = parseArgs(args)
    if #countries == 0 then return "" end

    local mapHtml   = buildMap(frame, countries)
    local tableHtml = buildTable(countries)
    return mapHtml .. "\n"
        .. '<div class="legal-status-search">' .. tableHtml .. '</div>'
end

return p
