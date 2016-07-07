# encoding: utf-8
## year fiscal
puts "Import year settings"

def create_fyears(start_at,end_at,fyear,fyear_f,markjp,markjp_f,namejp,namejp_f)
  Gw::YearFiscalJp.create({
    start_at: start_at,end_at: end_at,fyear: fyear,
    fyear_f: fyear_f,markjp: markjp,markjp_f: markjp_f,namejp: namejp,namejp_f: namejp_f
  })
end

def create_year_marks(name, mark, start_at)
  Gw::YearMarkJp.create({
    name: name, mark: mark, start_at: start_at
  })
end

create_year_marks('明治', 'M', '1868-09-08 00:00:00')
create_year_marks('大正', 'T', '1912-07-30 00:00:00')
create_year_marks('昭和', 'S', '1926-12-25 00:00:00')
create_year_marks('平成', 'H', '1989-01-08 00:00:00')


create_fyears("1869-04-01 00:00:00","1870-03-31 23:59:59",1869,"1869年度","M2","M2年度","明治2","明治2年度")
create_fyears("1870-04-01 00:00:00","1871-03-31 23:59:59",1870,"1870年度","M3","M3年度","明治3","明治3年度")
create_fyears("1871-04-01 00:00:00","1872-03-31 23:59:59",1871,"1871年度","M4","M4年度","明治4","明治4年度")
create_fyears("1872-04-01 00:00:00","1873-03-31 23:59:59",1872,"1872年度","M5","M5年度","明治5","明治5年度")
create_fyears("1873-04-01 00:00:00","1874-03-31 23:59:59",1873,"1873年度","M6","M6年度","明治6","明治6年度")
create_fyears("1874-04-01 00:00:00","1875-03-31 23:59:59",1874,"1874年度","M7","M7年度","明治7","明治7年度")
create_fyears("1875-04-01 00:00:00","1876-03-31 23:59:59",1875,"1875年度","M8","M8年度","明治8","明治8年度")
create_fyears("1876-04-01 00:00:00","1877-03-31 23:59:59",1876,"1876年度","M9","M9年度","明治9","明治9年度")
create_fyears("1877-04-01 00:00:00","1878-03-31 23:59:59",1877,"1877年度","M10","M10年度","明治10","明治10年度")
create_fyears("1878-04-01 00:00:00","1879-03-31 23:59:59",1878,"1878年度","M11","M11年度","明治11","明治11年度")
create_fyears("1879-04-01 00:00:00","1880-03-31 23:59:59",1879,"1879年度","M12","M12年度","明治12","明治12年度")
create_fyears("1880-04-01 00:00:00","1881-03-31 23:59:59",1880,"1880年度","M13","M13年度","明治13","明治13年度")
create_fyears("1881-04-01 00:00:00","1882-03-31 23:59:59",1881,"1881年度","M14","M14年度","明治14","明治14年度")
create_fyears("1882-04-01 00:00:00","1883-03-31 23:59:59",1882,"1882年度","M15","M15年度","明治15","明治15年度")
create_fyears("1883-04-01 00:00:00","1884-03-31 23:59:59",1883,"1883年度","M16","M16年度","明治16","明治16年度")
create_fyears("1884-04-01 00:00:00","1885-03-31 23:59:59",1884,"1884年度","M17","M17年度","明治17","明治17年度")
create_fyears("1885-04-01 00:00:00","1886-03-31 23:59:59",1885,"1885年度","M18","M18年度","明治18","明治18年度")
create_fyears("1886-04-01 00:00:00","1887-03-31 23:59:59",1886,"1886年度","M19","M19年度","明治19","明治19年度")
create_fyears("1887-04-01 00:00:00","1888-03-31 23:59:59",1887,"1887年度","M20","M20年度","明治20","明治20年度")
create_fyears("1888-04-01 00:00:00","1889-03-31 23:59:59",1888,"1888年度","M21","M21年度","明治21","明治21年度")
create_fyears("1889-04-01 00:00:00","1890-03-31 23:59:59",1889,"1889年度","M22","M22年度","明治22","明治22年度")
create_fyears("1890-04-01 00:00:00","1891-03-31 23:59:59",1890,"1890年度","M23","M23年度","明治23","明治23年度")
create_fyears("1891-04-01 00:00:00","1892-03-31 23:59:59",1891,"1891年度","M24","M24年度","明治24","明治24年度")
create_fyears("1892-04-01 00:00:00","1893-03-31 23:59:59",1892,"1892年度","M25","M25年度","明治25","明治25年度")
create_fyears("1893-04-01 00:00:00","1894-03-31 23:59:59",1893,"1893年度","M26","M26年度","明治26","明治26年度")
create_fyears("1894-04-01 00:00:00","1895-03-31 23:59:59",1894,"1894年度","M27","M27年度","明治27","明治27年度")
create_fyears("1895-04-01 00:00:00","1896-03-31 23:59:59",1895,"1895年度","M28","M28年度","明治28","明治28年度")
create_fyears("1896-04-01 00:00:00","1897-03-31 23:59:59",1896,"1896年度","M29","M29年度","明治29","明治29年度")
create_fyears("1897-04-01 00:00:00","1898-03-31 23:59:59",1897,"1897年度","M30","M30年度","明治30","明治30年度")
create_fyears("1898-04-01 00:00:00","1899-03-31 23:59:59",1898,"1898年度","M31","M31年度","明治31","明治31年度")
create_fyears("1899-04-01 00:00:00","1900-03-31 23:59:59",1899,"1899年度","M32","M32年度","明治32","明治32年度")
create_fyears("1900-04-01 00:00:00","1901-03-31 23:59:59",1900,"1900年度","M33","M33年度","明治33","明治33年度")
create_fyears("1901-04-01 00:00:00","1902-03-31 23:59:59",1901,"1901年度","M34","M34年度","明治34","明治34年度")
create_fyears("1902-04-01 00:00:00","1903-03-31 23:59:59",1902,"1902年度","M35","M35年度","明治35","明治35年度")
create_fyears("1903-04-01 00:00:00","1904-03-31 23:59:59",1903,"1903年度","M36","M36年度","明治36","明治36年度")
create_fyears("1904-04-01 00:00:00","1905-03-31 23:59:59",1904,"1904年度","M37","M37年度","明治37","明治37年度")
create_fyears("1905-04-01 00:00:00","1906-03-31 23:59:59",1905,"1905年度","M38","M38年度","明治38","明治38年度")
create_fyears("1906-04-01 00:00:00","1907-03-31 23:59:59",1906,"1906年度","M39","M39年度","明治39","明治39年度")
create_fyears("1907-04-01 00:00:00","1908-03-31 23:59:59",1907,"1907年度","M40","M40年度","明治40","明治40年度")
create_fyears("1908-04-01 00:00:00","1909-03-31 23:59:59",1908,"1908年度","M41","M41年度","明治41","明治41年度")
create_fyears("1909-04-01 00:00:00","1910-03-31 23:59:59",1909,"1909年度","M42","M42年度","明治42","明治42年度")
create_fyears("1910-04-01 00:00:00","1911-03-31 23:59:59",1910,"1910年度","M43","M43年度","明治43","明治43年度")
create_fyears("1911-04-01 00:00:00","1912-03-31 23:59:59",1911,"1911年度","M44","M44年度","明治44","明治44年度")
create_fyears("1912-04-01 00:00:00","1913-03-31 23:59:59",1912,"1912年度","M45","M45年度","明治45","明治45年度")
create_fyears("1913-04-01 00:00:00","1914-03-31 23:59:59",1913,"1913年度","T2","T2年度","大正2","大正2年度")
create_fyears("1914-04-01 00:00:00","1915-03-31 23:59:59",1914,"1914年度","T3","T3年度","大正3","大正3年度")
create_fyears("1915-04-01 00:00:00","1916-03-31 23:59:59",1915,"1915年度","T4","T4年度","大正4","大正4年度")
create_fyears("1916-04-01 00:00:00","1917-03-31 23:59:59",1916,"1916年度","T5","T5年度","大正5","大正5年度")
create_fyears("1917-04-01 00:00:00","1918-03-31 23:59:59",1917,"1917年度","T6","T6年度","大正6","大正6年度")
create_fyears("1918-04-01 00:00:00","1919-03-31 23:59:59",1918,"1918年度","T7","T7年度","大正7","大正7年度")
create_fyears("1919-04-01 00:00:00","1920-03-31 23:59:59",1919,"1919年度","T8","T8年度","大正8","大正8年度")
create_fyears("1920-04-01 00:00:00","1921-03-31 23:59:59",1920,"1920年度","T9","T9年度","大正9","大正9年度")
create_fyears("1921-04-01 00:00:00","1922-03-31 23:59:59",1921,"1921年度","T10","T10年度","大正10","大正10年度")
create_fyears("1922-04-01 00:00:00","1923-03-31 23:59:59",1922,"1922年度","T11","T11年度","大正11","大正11年度")
create_fyears("1923-04-01 00:00:00","1924-03-31 23:59:59",1923,"1923年度","T12","T12年度","大正12","大正12年度")
create_fyears("1924-04-01 00:00:00","1925-03-31 23:59:59",1924,"1924年度","T13","T13年度","大正13","大正13年度")
create_fyears("1925-04-01 00:00:00","1926-03-31 23:59:59",1925,"1925年度","T14","T14年度","大正14","大正14年度")
create_fyears("1926-04-01 00:00:00","1927-03-31 23:59:59",1926,"1926年度","T15","T15年度","大正15","大正15年度")
create_fyears("1927-04-01 00:00:00","1928-03-31 23:59:59",1927,"1927年度","S2","S2年度","昭和2","昭和2年度")
create_fyears("1928-04-01 00:00:00","1929-03-31 23:59:59",1928,"1928年度","S3","S3年度","昭和3","昭和3年度")
create_fyears("1929-04-01 00:00:00","1930-03-31 23:59:59",1929,"1929年度","S4","S4年度","昭和4","昭和4年度")
create_fyears("1930-04-01 00:00:00","1931-03-31 23:59:59",1930,"1930年度","S5","S5年度","昭和5","昭和5年度")
create_fyears("1931-04-01 00:00:00","1932-03-31 23:59:59",1931,"1931年度","S6","S6年度","昭和6","昭和6年度")
create_fyears("1932-04-01 00:00:00","1933-03-31 23:59:59",1932,"1932年度","S7","S7年度","昭和7","昭和7年度")
create_fyears("1933-04-01 00:00:00","1934-03-31 23:59:59",1933,"1933年度","S8","S8年度","昭和8","昭和8年度")
create_fyears("1934-04-01 00:00:00","1935-03-31 23:59:59",1934,"1934年度","S9","S9年度","昭和9","昭和9年度")
create_fyears("1935-04-01 00:00:00","1936-03-31 23:59:59",1935,"1935年度","S10","S10年度","昭和10","昭和10年度")
create_fyears("1936-04-01 00:00:00","1937-03-31 23:59:59",1936,"1936年度","S11","S11年度","昭和11","昭和11年度")
create_fyears("1937-04-01 00:00:00","1938-03-31 23:59:59",1937,"1937年度","S12","S12年度","昭和12","昭和12年度")
create_fyears("1938-04-01 00:00:00","1939-03-31 23:59:59",1938,"1938年度","S13","S13年度","昭和13","昭和13年度")
create_fyears("1939-04-01 00:00:00","1940-03-31 23:59:59",1939,"1939年度","S14","S14年度","昭和14","昭和14年度")
create_fyears("1940-04-01 00:00:00","1941-03-31 23:59:59",1940,"1940年度","S15","S15年度","昭和15","昭和15年度")
create_fyears("1941-04-01 00:00:00","1942-03-31 23:59:59",1941,"1941年度","S16","S16年度","昭和16","昭和16年度")
create_fyears("1942-04-01 00:00:00","1943-03-31 23:59:59",1942,"1942年度","S17","S17年度","昭和17","昭和17年度")
create_fyears("1943-04-01 00:00:00","1944-03-31 23:59:59",1943,"1943年度","S18","S18年度","昭和18","昭和18年度")
create_fyears("1944-04-01 00:00:00","1945-03-31 23:59:59",1944,"1944年度","S19","S19年度","昭和19","昭和19年度")
create_fyears("1945-04-01 00:00:00","1946-03-31 23:59:59",1945,"1945年度","S20","S20年度","昭和20","昭和20年度")
create_fyears("1946-04-01 00:00:00","1947-03-31 23:59:59",1946,"1946年度","S21","S21年度","昭和21","昭和21年度")
create_fyears("1947-04-01 00:00:00","1948-03-31 23:59:59",1947,"1947年度","S22","S22年度","昭和22","昭和22年度")
create_fyears("1948-04-01 00:00:00","1949-03-31 23:59:59",1948,"1948年度","S23","S23年度","昭和23","昭和23年度")
create_fyears("1949-04-01 00:00:00","1950-03-31 23:59:59",1949,"1949年度","S24","S24年度","昭和24","昭和24年度")
create_fyears("1950-04-01 00:00:00","1951-03-31 23:59:59",1950,"1950年度","S25","S25年度","昭和25","昭和25年度")
create_fyears("1951-04-01 00:00:00","1952-03-31 23:59:59",1951,"1951年度","S26","S26年度","昭和26","昭和26年度")
create_fyears("1952-04-01 00:00:00","1953-03-31 23:59:59",1952,"1952年度","S27","S27年度","昭和27","昭和27年度")
create_fyears("1953-04-01 00:00:00","1954-03-31 23:59:59",1953,"1953年度","S28","S28年度","昭和28","昭和28年度")
create_fyears("1954-04-01 00:00:00","1955-03-31 23:59:59",1954,"1954年度","S29","S29年度","昭和29","昭和29年度")
create_fyears("1955-04-01 00:00:00","1956-03-31 23:59:59",1955,"1955年度","S30","S30年度","昭和30","昭和30年度")
create_fyears("1956-04-01 00:00:00","1957-03-31 23:59:59",1956,"1956年度","S31","S31年度","昭和31","昭和31年度")
create_fyears("1957-04-01 00:00:00","1958-03-31 23:59:59",1957,"1957年度","S32","S32年度","昭和32","昭和32年度")
create_fyears("1958-04-01 00:00:00","1959-03-31 23:59:59",1958,"1958年度","S33","S33年度","昭和33","昭和33年度")
create_fyears("1959-04-01 00:00:00","1960-03-31 23:59:59",1959,"1959年度","S34","S34年度","昭和34","昭和34年度")
create_fyears("1960-04-01 00:00:00","1961-03-31 23:59:59",1960,"1960年度","S35","S35年度","昭和35","昭和35年度")
create_fyears("1961-04-01 00:00:00","1962-03-31 23:59:59",1961,"1961年度","S36","S36年度","昭和36","昭和36年度")
create_fyears("1962-04-01 00:00:00","1963-03-31 23:59:59",1962,"1962年度","S37","S37年度","昭和37","昭和37年度")
create_fyears("1963-04-01 00:00:00","1964-03-31 23:59:59",1963,"1963年度","S38","S38年度","昭和38","昭和38年度")
create_fyears("1964-04-01 00:00:00","1965-03-31 23:59:59",1964,"1964年度","S39","S39年度","昭和39","昭和39年度")
create_fyears("1965-04-01 00:00:00","1966-03-31 23:59:59",1965,"1965年度","S40","S40年度","昭和40","昭和40年度")
create_fyears("1966-04-01 00:00:00","1967-03-31 23:59:59",1966,"1966年度","S41","S41年度","昭和41","昭和41年度")
create_fyears("1967-04-01 00:00:00","1968-03-31 23:59:59",1967,"1967年度","S42","S42年度","昭和42","昭和42年度")
create_fyears("1968-04-01 00:00:00","1969-03-31 23:59:59",1968,"1968年度","S43","S43年度","昭和43","昭和43年度")
create_fyears("1969-04-01 00:00:00","1970-03-31 23:59:59",1969,"1969年度","S44","S44年度","昭和44","昭和44年度")
create_fyears("1970-04-01 00:00:00","1971-03-31 23:59:59",1970,"1970年度","S45","S45年度","昭和45","昭和45年度")
create_fyears("1971-04-01 00:00:00","1972-03-31 23:59:59",1971,"1971年度","S46","S46年度","昭和46","昭和46年度")
create_fyears("1972-04-01 00:00:00","1973-03-31 23:59:59",1972,"1972年度","S47","S47年度","昭和47","昭和47年度")
create_fyears("1973-04-01 00:00:00","1974-03-31 23:59:59",1973,"1973年度","S48","S48年度","昭和48","昭和48年度")
create_fyears("1974-04-01 00:00:00","1975-03-31 23:59:59",1974,"1974年度","S49","S49年度","昭和49","昭和49年度")
create_fyears("1975-04-01 00:00:00","1976-03-31 23:59:59",1975,"1975年度","S50","S50年度","昭和50","昭和50年度")
create_fyears("1976-04-01 00:00:00","1977-03-31 23:59:59",1976,"1976年度","S51","S51年度","昭和51","昭和51年度")
create_fyears("1977-04-01 00:00:00","1978-03-31 23:59:59",1977,"1977年度","S52","S52年度","昭和52","昭和52年度")
create_fyears("1978-04-01 00:00:00","1979-03-31 23:59:59",1978,"1978年度","S53","S53年度","昭和53","昭和53年度")
create_fyears("1979-04-01 00:00:00","1980-03-31 23:59:59",1979,"1979年度","S54","S54年度","昭和54","昭和54年度")
create_fyears("1980-04-01 00:00:00","1981-03-31 23:59:59",1980,"1980年度","S55","S55年度","昭和55","昭和55年度")
create_fyears("1981-04-01 00:00:00","1982-03-31 23:59:59",1981,"1981年度","S56","S56年度","昭和56","昭和56年度")
create_fyears("1982-04-01 00:00:00","1983-03-31 23:59:59",1982,"1982年度","S57","S57年度","昭和57","昭和57年度")
create_fyears("1983-04-01 00:00:00","1984-03-31 23:59:59",1983,"1983年度","S58","S58年度","昭和58","昭和58年度")
create_fyears("1984-04-01 00:00:00","1985-03-31 23:59:59",1984,"1984年度","S59","S59年度","昭和59","昭和59年度")
create_fyears("1985-04-01 00:00:00","1986-03-31 23:59:59",1985,"1985年度","S60","S60年度","昭和60","昭和60年度")
create_fyears("1986-04-01 00:00:00","1987-03-31 23:59:59",1986,"1986年度","S61","S61年度","昭和61","昭和61年度")
create_fyears("1987-04-01 00:00:00","1988-03-31 23:59:59",1987,"1987年度","S62","S62年度","昭和62","昭和62年度")
create_fyears("1988-04-01 00:00:00","1989-03-31 23:59:59",1988,"1988年度","S63","S63年度","昭和63","昭和63年度")
create_fyears("1989-04-01 00:00:00","1990-03-31 23:59:59",1989,"1989年度","H1","H1年度","平成1","平成1年度")
create_fyears("1990-04-01 00:00:00","1991-03-31 23:59:59",1990,"1990年度","H2","H2年度","平成2","平成2年度")
create_fyears("1991-04-01 00:00:00","1992-03-31 23:59:59",1991,"1991年度","H3","H3年度","平成3","平成3年度")
create_fyears("1992-04-01 00:00:00","1993-03-31 23:59:59",1992,"1992年度","H4","H4年度","平成4","平成4年度")
create_fyears("1993-04-01 00:00:00","1994-03-31 23:59:59",1993,"1993年度","H5","H5年度","平成5","平成5年度")
create_fyears("1994-04-01 00:00:00","1995-03-31 23:59:59",1994,"1994年度","H6","H6年度","平成6","平成6年度")
create_fyears("1995-04-01 00:00:00","1996-03-31 23:59:59",1995,"1995年度","H7","H7年度","平成7","平成7年度")
create_fyears("1996-04-01 00:00:00","1997-03-31 23:59:59",1996,"1996年度","H8","H8年度","平成8","平成8年度")
create_fyears("1997-04-01 00:00:00","1998-03-31 23:59:59",1997,"1997年度","H9","H9年度","平成9","平成9年度")
create_fyears("1998-04-01 00:00:00","1999-03-31 23:59:59",1998,"1998年度","H10","H10年度","平成10","平成10年度")
create_fyears("1999-04-01 00:00:00","2000-03-31 23:59:59",1999,"1999年度","H11","H11年度","平成11","平成11年度")
create_fyears("2000-04-01 00:00:00","2001-03-31 23:59:59",2000,"2000年度","H12","H12年度","平成12","平成12年度")
create_fyears("2001-04-01 00:00:00","2002-03-31 23:59:59",2001,"2001年度","H13","H13年度","平成13","平成13年度")
create_fyears("2002-04-01 00:00:00","2003-03-31 23:59:59",2002,"2002年度","H14","H14年度","平成14","平成14年度")
create_fyears("2003-04-01 00:00:00","2004-03-31 23:59:59",2003,"2003年度","H15","H15年度","平成15","平成15年度")
create_fyears("2004-04-01 00:00:00","2005-03-31 23:59:59",2004,"2004年度","H16","H16年度","平成16","平成16年度")
create_fyears("2005-04-01 00:00:00","2006-03-31 23:59:59",2005,"2005年度","H17","H17年度","平成17","平成17年度")
create_fyears("2006-04-01 00:00:00","2007-03-31 23:59:59",2006,"2006年度","H18","H18年度","平成18","平成18年度")
create_fyears("2007-04-01 00:00:00","2008-03-31 23:59:59",2007,"2007年度","H19","H19年度","平成19","平成19年度")
create_fyears("2008-04-01 00:00:00","2009-03-31 23:59:59",2008,"2008年度","H20","H20年度","平成20","平成20年度")
create_fyears("2009-04-01 00:00:00","2010-03-31 23:59:59",2009,"2009年度","H21","H21年度","平成21","平成21年度")
create_fyears("2010-04-01 00:00:00","2011-03-31 23:59:59",2010,"2010年度","H22","H22年度","平成22","平成22年度")
create_fyears("2011-04-01 00:00:00","2012-03-31 23:59:59",2011,"2011年度","H23","H23年度","平成23","平成23年度")
create_fyears("2012-04-01 00:00:00","2013-03-31 23:59:59",2012,"2012年度","H24","H24年度","平成24","平成24年度")
