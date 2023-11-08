
;;;===Classes===============================================================
(defclass IP_recomendation
    (is-a USER)
    (role concrete)
    (slot interestPoint
        (type INSTANCE)
        (create-accessor read-write))
    (slot puntuacio
        (type INTEGER)
        (create-accessor read-write)))

(defclass City_recomendation 
    (is-a USER)
    (role concrete)
    (slot ciutat
        (type INSTANCE)
        (create-accessor read-write))
    (slot puntuacio
        (type INTEGER)
        (create-accessor read-write)))

(defclass Estada
    (is-a USER)
    (role concrete)
    (slot ciutat
        (type INSTANCE)
        (create-accessor read-write))
    (slot number_of_days
        (type INTEGER)
        (create-accessor read-write))
    (slot hotel
        (type INSTANCE)
        (create-accessor read-write))
    (multislot IPs_to_visit
        (type INSTANCE)
        (create-accessor read-write)))

(defclass Trip
    (is-a USER)
    (role concrete)
    (multislot Estades
        (type INSTANCE)
        (create-accessor read-write))
)

;;;=========================================================================

;;;===Modules===============================================================
(defmodule MAIN (export ?ALL))

(defmodule INFORMACIO
    (import MAIN ?ALL)
    (export ?ALL))

(defmodule PROCESSAT
    (import MAIN ?ALL)
    (export ?ALL))

(defmodule CAMI
    (import MAIN ?ALL)
    (export ?ALL))

(defmodule PRESENTACIO
    (import MAIN ?ALL)
    (export ?ALL))
;;;=========================================================================

;;;===Templates=============================================================
(deftemplate MAIN::Usuari
    (slot nom (type STRING))
    (slot ciutat (type INSTANCE)))

(deftemplate MAIN::Preferencies
    (slot number_of_days (type INTEGER) (default -1))
    (slot number_of_cities (type INTEGER) (default -1))
    (slot trip_cost (type SYMBOL) (allowed-symbols baix mitja alt))
    (slot transport (type SYMBOL) (allowed-symbols indefinit cotxe tren vaixell)
        (default indefinit))
    (slot familiar (type SYMBOL) (allowed-symbols TRUE FALSE) (default FALSE))
    (slot romantic (type SYMBOL) (allowed-symbols TRUE FALSE) (default FALSE))
    (slot desconnexio (type SYMBOL) (allowed-symbols TRUE FALSE) (default FALSE))
    (slot cultural (type SYMBOL) (allowed-symbols TRUE FALSE) (default FALSE))
    (slot public-orientat (type SYMBOL) (allowed-symbols Junior Senior Veteran)))
;;;=========================================================================

;;;===Funcions==============================================================
(deffunction INFORMACIO::pregunta-general (?question)
    (format t "%s " ?question)
    (bind ?answer (read))
    (while (not (lexemep ?answer)) do
        (format t "%s " ?answer)
        (bind ?answer (read)))
    ?answer)

(deffunction INFORMACIO::pregunta-opcions (?question $?allowed-values)
    (format t "%s "?question)
    (progn$ (?curr-value $?allowed-values)
        (format t "[%s]" ?curr-value))
    (printout t ": ")
    (bind ?answer (read))
    (while (not (member$ ?answer ?allowed-values)) do
        (format t "%s "?question)
        (progn$ (?curr-value $?allowed-values)
            (format t "[%s]" ?curr-value))
        (printout t ": ")
        (bind ?answer (read)))
    ?answer)
   
(deffunction INFORMACIO::pregunta-si-no (?question)
   (bind ?answer (pregunta-opcions ?question si no))
   (if (or (eq ?answer si) (eq ?answer s))
      then TRUE 
      else FALSE))

(deffunction INFORMACIO::pregunta-numerica (?question ?ini_range ?end_range)
    (format t "%s [%d, %d] " ?question ?ini_range ?end_range)
    (bind ?answer (read))
    (while (not(and(>= ?answer ?ini_range)(<= ?answer ?end_range))) do
        (format t "%s [%d, %d] " ?question ?ini_range ?end_range)
        (bind ?answer (read)))
    ?answer)

(deffunction INFORMACIO::pertany (?nom ?ciutats)
    (bind ?r -1)
    (loop-for-count (?i 1 (length$ ?ciutats))
        (bind ?aux (nth$ ?i ?ciutats))
        (if (eq ?nom (send ?aux get-NameCity))
            then (bind ?r ?i)))
    ?r)

(deffunction CAMI::get-euclidean-distance(?ciu1 ?ciu2)
    (bind ?posx1 (send ?ciu1 get-latitude))
    (bind ?posy1 (send ?ciu1 get-longitude))
    (bind ?posx2 (send ?ciu2 get-latitude))
    (bind ?posy2 (send ?ciu2 get-longitude))
    (bind ?x (- ?posx2 ?posx1)) (bind ?x (* ?x ?x))
    (bind ?y (- ?posy2 ?posy1)) (bind ?y (* ?y ?y))
    (bind ?distance (+ ?x ?y)) (bind ?distance (sqrt ?distance))
    ?distance)

(deffunction CAMI::can-get-to-city (?origen ?curr-city ?tr)
    (bind ?res TRUE)
        (switch ?tr
            (case cotxe then 
                (bind $?bycar (send ?origen get-travByCar))
                (if (eq (member$ ?curr-city ?bycar) FALSE) then 
                    (bind ?res FALSE))) ;maybe es $?
            (case tren then 
                (bind $?bytrain (send ?origen get-travByTrain))
                (if (eq (member$ ?curr-city ?bytrain) FALSE) then 
                     (bind ?res FALSE))) ;maybe es $?
            (case vaixell then 
                (bind $?byboat (send ?origen get-travByBoat))
                (if (eq (member$ ?curr-city ?byboat) FALSE) then 
                    (bind ?res FALSE)))) ;maybe es $?
        ?res)

(deffunction CAMI::get-next-city(?origen ?recomenacions ?transport)
    (bind ?city (send (nth$ 1 ?recomenacions) get-ciutat))
    (bind ?best_city ?city)

    (bind ?puntuacio (send (nth$ 1 ?recomenacions) get-puntuacio))
    (bind ?distance (get-euclidean-distance ?origen ?city))
    (if (eq ?distance 0.0) then (bind ?distance 1))
    ;(printout t ?puntuacio ", " ?distance crlf)
    (bind ?ratio (/ ?puntuacio ?distance))
    (bind ?best_ratio ?ratio)
    (bind ?a_eliminar (nth$ 1 ?recomenacions))

    (loop-for-count (?i 2 (length$ ?recomenacions))
        (bind ?city (send (nth$ ?i ?recomenacions) get-ciutat))
        (bind ?puntuacio (send (nth$ ?i ?recomenacions) get-puntuacio))
        (bind ?distance (get-euclidean-distance ?origen ?city))
        (if (eq ?distance 0.0) then (bind ?distance 1))
        ;(printout t ?puntuacio ", " ?distance crlf)

        (bind ?ratio (/ ?puntuacio ?distance))
        (if (> ?ratio ?best_ratio) then
            (if (eq (can-get-to-city ?origen ?city ?transport) TRUE) then
                (bind ?a_eliminar (nth$ ?i ?recomenacions))
                (bind ?best_ratio ?ratio)
                (bind ?best_city ?city))))
    (send ?a_eliminar delete)
    ?best_city)

(deffunction CAMI::generate-path (?origen ?nCities ?transport)
    ;(printout t "nCities: " ?nCities crlf)
    (bind $?cami (create$))
    (bind ?ant ?origen)
    (loop-for-count (?i 1 ?nCities) do
        ;(printout t "iteracio " ?i " de " ?nCities crlf)
        (bind $?ciutats (find-all-instances ((?inst City_recomendation)) TRUE))
        (bind ?ant (get-next-city ?ant ?ciutats ?transport))
        (bind $?cami (insert$ $?cami (+ (length$ $?cami) 1) ?ant)))
    ?cami)

(deffunction CAMI::trobar-ips (?ciutat ?nDays)
    (bind ?nIPs (* ?nDays 4))
    (bind ?llista (create$ ))
    (bind $?IP_reals (send ?ciutat get-hasInterestPoints))
    
    (loop-for-count (?i 1 ?nIPs)

        (bind ?IPs2 (find-all-instances ((?inst IP_recomendation)) (member$ ?inst::interestPoint $?IP_reals)))

        (bind ?millor_IP (nth$ 1 $?IPs))

        (progn$ (?j $?IPs2)
            (if (< (send ?millor_IP get-puntuacio) (send ?j get-puntuacio)) then
                (bind ?millor_IP ?j)))
        (bind $?llista (insert$ $?llista (+ (length$ $?llista) 1) ?millor_IP))
        (send ?millor_IP delete))
    ?llista)
;;;=========================================================================

;;;===Message Handler=======================================================
(defmessage-handler PROCESSAT::interestPoint print-ipoint ()
    (printout t "-----------------------------------")
    (printout t crlf)
    (printout t ?self:Name)
    (printout t crlf)
    (bind ?c (send ?self get-cultural))
    (if (eq ?c TRUE)
        then (printout t "It is a cultural atraction")
        else (printout t "It is not a cultural atraction"))
    (printout t crlf)
    (bind ?f (send ?self get-forFamilies))
    (if (eq ?f TRUE)
        then (printout t "Recommended for families")
        else (printout t "Not recommended for families"))
    (printout t crlf)
    (printout t "Age of tourism: " crlf)
    (progn$ (?curr-age ?self:publicAge)
        (printout t ?curr-age crlf))
    (printout t crlf)
    (printout t "-----------------------------------")
    (printout t crlf))

(defmessage-handler PROCESSAT::City print-city ()
    (printout t "-----------------------------------")
    (printout t crlf)
    (printout t ?self:NameCity)
    (printout t crlf)
    (printout t "city life quality: " ?self:lifeQuality)
    (printout t crlf)
    (printout t "city public: " ?self:cityType)
    (printout t crlf)
    (printout t "Interesting points in this city: " crlf)
    (progn$ (?curr-ip ?self:hasInterestPoints)
        (printout t (send ?curr-ip print-ipoint) crlf))
    (printout t crlf)
    (printout t "-----------------------------------")
    (printout t crlf))
;;;=========================================================================

;;;===Regles INFORMACIO=====================================================
(defrule MAIN::initialRule
    "Regla inicial"
    =>
    (printout t "________________________________________________________")
    (printout t crlf "Sistema de recomanació de viatges" crlf)
    (printout t "Desenvolupat per Jordi Foix, Guillem Rosselló i Miquel Gómez")
    (printout t crlf)
    (printout t "________________________________________________________")
    (printout t crlf)
    (focus INFORMACIO))

(defrule INFORMACIO::establir-info-usuari
    "Establim el nom de l'usuari i la ciutat d'origen (la qual ha de ser al sistema)"
    ;;;L'entrada de a ciutat de l'usuari ha de ser amb cometes ("nom_ciutat")
    (declare (salience 10))
    (not (Usuari))
    =>
    (bind ?nom_usuari (pregunta-general "Quin és el nom de l'usuari?"))
    (bind $?llista (find-all-instances ((?inst City)) TRUE))
    (printout t "Ciutats disponibles: ")
    (progn$ (?i ?llista)
        (printout t (send ?i get-NameCity) " "))
    (printout t crlf)
    (bind ?c (pregunta-general "Quina és la ciutat de l'usuari? (Escriu-la entre cometes) "))
    (bind ?index (pertany ?c ?llista))

    (while (eq ?index -1) do
        (printout t "La ciutat no es troba al Sistema" crlf)
        (bind ?c (pregunta-general "Quina és la ciutat de l'usuari? (Escriu-la entre cometes) "))
        (bind ?index (pertany ?c ?llista)))
    (bind ?nova_ciutat (nth$ ?index ?llista))
    (assert (Usuari (nom ?nom_usuari) (ciutat ?nova_ciutat) )))

(defrule INFORMACIO::mostrar-info-usuari
    "Mostra informació de l'usuari"
    ?u <- (Usuari (nom ?n) (ciutat ?c))
    =>
    (printout t crlf)
    (printout t "Nom: " ?n crlf)
    (printout t "Ciutat: " ?c crlf)
    (printout t crlf))

(defrule INFORMACIO::establir-preferencies
    "Establim les preferencies de l'usuari"
    (not (Preferencies))
    =>
    (bind ?nd (pregunta-numerica "Quants dies ha de durar el viatge?" 1 30))
    (bind ?nc (pregunta-numerica "Quantse ciutats es volen visitar?" 1 ?nd))
    (bind ?tc (pregunta-opcions "Quin és el pressupost del viatge?" baix mitja alt))
    (bind ?transport "indefinit")
    (if (not (eq ?tc baix)) then
        (bind ?cotxe (pregunta-si-no "El viatge es realitzarà únicament en cotxe?"))
        (if (eq ?cotxe TRUE)
            then (bind ?transport "cotxe")
            else (bind ?tren (pregunta-si-no "El viatge es realitzarà únicament en tren?"))
            (if (eq ?tren TRUE)
                then (bind ?transport "tren")
                else (bind ?vaixell (pregunta-si-no "El viatge es realitzarà únicament en vaixell?"))
                (if (eq ?vaixell TRUE)
                    then (bind ?transport "tren")))))
    (bind ?f (pregunta-si-no "Es tracta d'un viatge familiar?"))
    (bind ?r (pregunta-si-no "Es tracta d'un viatge romantic?"))
    (bind ?d (pregunta-si-no "Es tracta d'un viatge de desconnexio?"))
    (bind ?c (pregunta-si-no "Es tracta d'un viatge cultural?"))
    (if (eq ?f FALSE) then
        (bind ?o (pregunta-opcions "A quin public esta orientat el viatge?" Junior Senior Veteran))
        (assert (Preferencies (number_of_days ?nd) (number_of_cities ?nc) (trip_cost ?tc) 
            (transport ?transport) (familiar ?f) (romantic ?r) (desconnexio ?d) (cultural ?c)
            (public-orientat ?o)))
    else (assert (Preferencies (number_of_days ?nd) (number_of_cities ?nc) (trip_cost ?tc)
        (transport ?transport) (familiar ?f) (romantic ?r) (desconnexio ?d) (cultural ?c)))))
   
(defrule INFORMACIO::mostrar-preferencies
    "Mostra les preferencies del viatge"
    ?p <- (Preferencies (number_of_days ?nd) (number_of_cities ?nc) (trip_cost ?tc) (transport ?t) (familiar ?f)
        (romantic ?r) (desconnexio ?d) (cultural ?c) (public-orientat ?o))
    =>
    (printout t crlf)
    (printout t "# dies: " ?nd crlf)
    (printout t "# ciutats: " ?nc crlf)
    (printout t "Pressupost: " ?tc crlf)
    (printout t "Transport: " ?t crlf)
    (if (eq ?f TRUE) then (printout t "Viatge familiar" crlf))
    (if (eq ?r TRUE) then (printout t "Viatge romantic" crlf))
    (if (eq ?d TRUE) then (printout t "Viatge de desconnexio" crlf))
    (if (eq ?c TRUE) then (printout t "Viatge cultural" crlf))
    (if (eq ?f False) then (printout t "Viatge orientat a " ?o crlf))
    (printout t crlf)
    (focus PROCESSAT))
;;;=========================================================================

;;;===Regles PROCESSAT======================================================
(defrule PROCESSAT::add-City
    "All cities added for posterior filtering"
    (declare (salience 10))
    (Usuari (ciutat ?ciutat))
    ?p <- (Preferencies)
    (not (City_recomendation))
    =>
    (bind $?llista (find-all-instances ((?inst City)) TRUE))
    (progn$ (?i ?llista)
        (if (not (eq (send ?ciutat get-NameCity) (send ?i get-NameCity))) then (make-instance (gensym) of City_recomendation (ciutat ?i) (puntuacio 0)))))

(defrule PROCESSAT::valorar-desconnexio
    "Eliminem touristic cities si volem desconnexio"
    (declare (salience 9))
    (eq 1 0)
    (Preferencies (desconnexio TRUE))
    ?r <- (object (is-a City_recomendation) (ciutat ?ciu))
    =>
    (if (eq touristic (send ?ciu get-cityType)) then (send ?r delete)))

(defrule PROCESSAT::valorar-no-desconnexio
    "Eliminem alternative cities si no volem desconnexio"
    (declare (salience 9))
    (eq 1 0)
    (Preferencies (desconnexio FALSE))
    ?r <- (object (is-a City_recomendation) (ciutat ?ciu))
    =>
    (if (eq alternative (send ?ciu get-cityType)) then (send ?r delete)))

(defrule PROCESSAT::valorar-pressupost-baix-amb-life-quality
    "Si l'usuari va lowCost, valorem la ciutat en funcio de la seva lifeQuality"
    (declare (salience 8))
    (Preferencies (trip_cost baix))
    ?r <- (object (is-a City_recomendation) (ciutat ?ciu) (puntuacio ?pun))
    (not (valorat-pressupost-baix-amb-life-quality ?ciu))
    =>
    (bind ?p ?pun)
    (if (eq (send ?ciu get-lifeQuality) lowCost) then (bind ?p (+ ?p 1)))
    (if (eq (send ?ciu get-lifeQuality) expensive) then (bind ?p (- ?p 1)))
    (send ?r put-puntuacio ?p)
    (assert (valorat-pressupost-baix-amb-life-quality ?ciu)))

(defrule PROCESSAT::valorar-pressupost-amb-relacio-costHotel
    (declare (salience 8))
    (Preferencies (trip_cost ?tc))
    ?r <- (object (is-a City_recomendation) (ciutat ?ciu) (puntuacio ?p))
    (not (valorat-hotels ?r))
    =>
    (bind $?hotels (send ?ciu get-hasHotels))
    (if (eq ?tc baix) then 
        (progn$ (?hotel $?hotels)
            (if (eq (send ?hotel get-price) lowCost) then (bind ?p (+ ?p 10)))
        )
    )
    (if (eq ?tc mitja) then
        (progn$ (?hotel $?hotels)
            (if (eq (send ?hotel get-price) lowCost) then (bind ?p (+ ?p 10)))
            (if (eq (send ?hotel get-price) regular) then (bind ?p (+ ?p 10)))
        )
    )
    (if (eq ?tc alt) then
        (progn$ (?hotel $?hotels)
            (if (eq (send ?hotel get-price) expensive) then (bind ?p (+ ?p 10)))
        )
    )
    (send ?r put-puntuacio ?p)
    (assert (valorat-hotels ?r)))

(defrule PROCESSAT::valorar-cultural
    "Incrementem puntuacio recomenacio en funcio dels IPs culturals/noCulturals"
    (declare (salience 8))
    (Preferencies (cultural ?c))
    ?r <- (object (is-a City_recomendation) (ciutat ?ciu) (puntuacio ?pun))
    (not (valorat-cultural ?ciu))
    =>
    (bind $?ips (send ?ciu get-hasInterestPoints))
    (bind ?punts ?pun)
    (progn$ (?ip $?ips)
            (if (eq (send ?ip get-cultural) ?c) then (bind ?punts (+ ?punts 1))))
    (send ?r put-puntuacio ?punts)
    (assert (valorat-cultural ?ciu)))

(defrule PROCESSAT::valorar-edat-usuari
    "Incrementem puntuacio recomenacio en funcio del nombre de IPs coherents amb edat usuari"
    (declare (salience 8))
    (Preferencies (familiar FALSE) (public-orientat ?o))
    ?r <- (object (is-a City_recomendation) (ciutat ?ciu) (puntuacio ?pun))
    (not (valorar-edat-usuari ?ciu))
    =>
    (bind ?punts ?pun)
    (bind $?ips (send ?ciu get-hasInterestPoints)) ;copiem a ?ips tots els interesting points de la ciutat ?ciu
    (progn$ (?ip $?ips) ;iterem per cada interesting point ?ip de la ciutat
        (bind $?edats (send ?ip get-publicAge)) ; assignem el multislot a la variable ?edats
        (progn$ (?edat $?edats)
            ;(printout t "o: " ?o ", edat: "?edat crlf) 
            (if (eq ?o Junior) then
                (if (eq ?edat Junior) then (bind ?punts (+ ?punts 1)))
                (if (eq ?edat Veteran) then (bind ?punts (- ?punts 1))))
            (if (eq ?o Senior) then
                (if (eq ?edat Senior) then (bind ?punts (+ ?punts 1))))
            (if (eq ?o Veteran) then
                (if (eq ?edat Veteran) then (bind ?punts (+ ?punts 1)))
                (if (eq ?edat Junior) then (bind ?punts (- ?punts 1))))))
    (send ?r put-puntuacio ?punts)
    (assert (valorar-edat-usuari ?ciu)))

(defrule PROCESSAT::valorar-familiar
    "Incrementem puntuacio recomenacio en funcio del nombre de IPs familiars/noFamiliars que te"
    (declare (salience 8))
    (Preferencies (familiar ?f))
    ?r <- (object (is-a City_recomendation) (ciutat ?ciu) (puntuacio ?p))
    (not (valorat-familiar ?r))
    =>
    (bind $?ips (send ?ciu get-hasInterestPoints))
    (progn$ (?ip $?ips)
        (if (eq (send ?ip get-forFamilies) ?f) then (bind ?p (+ ?p 10))))
    (send ?r put-puntuacio ?p)
    (assert (valorat-familiar ?r)))

(defrule PROCESSAT::canvi-a-cami
    "Canviem de focus despres de puntuar les ciutats"
    (declare (salience 0))
    =>
    (printout t "Anem a construir el camí" crlf)
    (focus CAMI))
;;;=========================================================================

;;;===Regles CAMI===========================================================
(defrule CAMI::buscar_cami
    "Busquem el primer cami"
    (declare (salience -1))
    (Usuari (ciutat ?origen))
    (Preferencies (number_of_days ?nDays) (number_of_cities ?nCities) (transport ?transport))
    =>
    ;(printout t "DROGA CARAMBOLA" crlf)
    (bind $?path1 (generate-path ?origen ?nCities ?transport))
    ;(printout t "mida del path: " (length$ $?path))
    ;(printout t crlf)
    ;(progn$ (?i ?path)
    ;    (printout t (send ?i print-city) crlf))
    (bind $?path2 (generate-path ?origen ?nCities ?transport))
    (assert (Path ?path1))
    (assert (Path ?path2))
    (assert (creacio-path 2)))

(defrule CAMI::generar-IPs
        (declare (salience 1))
        (Path ?path)
        ?x <- (creacio-path ?y)
        (test (> ?y 0))
        =>
        (progn$ (?city $?path)
                (bind $?ips (send ?city get-hasInterestPoints))
                (progn$ (?ip $?ips)
                        (make-instance (gensym) of IP_recomendation (interestPoint ?ip) (puntuacio 0))
                )
        )
        (modify ?x (creacio-path (- ?y 1))))

(defrule CAMI::puntuar-IPs
        ?ipr <- (object (is-a IP_recomendation) (interestPoint ?ip) (puntuacio ?pun))

        (Preferencies (familiar ?f) (cultural ?c) (public-orientat ?o))
        (not (puntuat-IP ?ip))
        =>
        (bind ?ip_f (send ?ip get-forFamilies))
        (bind ?ip_c (send ?ip get-cultural))
        (if (eq ?ip_f ?f) then (bind ?ip_pun 1))
        (if (eq ?ip_c ?c) then (bind ?ip_pun (+ ?ip_pun 1)))
        (bind ?ip_o (send ?ip get-publicAge))
        (progn$ (?i ?ip_o)
                (if (eq ?i ?o) then (bind ?ip_pun (+ ?ip_pun 1)))
        )
        (send ?ipr put-puntuacio ?ip_pun)
        (assert (puntuat-IP ?ip)))

(defrule CAMI::creacio-trip
        ?x <- (Path $?path)
        (Preferencies (number_of_days ?nDays) (trip_cost ?tc))
        =>
        (bind ?nCities (length$ $?path))
        
        (switch ?tc
                (case baix then (bind ?desired_price lowCost))
                (case mitja then (bind ?desired_price regular))
                (case alt then (bind ?desired_price expensive))
                ;(default lowCost)
        )
        (bind ?estades (create$ ))
        (bind ?days_per_city (div ?nDays ?nCities))
        (bind ?rest (mod ?nDays ?nCities))
        (bind $?llista_estades (create$))
        (progn$ (?city ?path)
                (bind $?hotels (send ?city get-hasHotels))
                (bind ?final_hotel (nth$ 1 ?hotels))
                (progn$ (?hotel $?hotels)
                        (if (eq (send ?hotel get-price) ?desired_price) then
                                (bind ?final_hotel ?hotel)
                                (break))
                )
                (bind $?ips (trobar-ips ?city ?nDays))
                (bind ?e (make-instance (gensym) of Estada (ciutat ?city) (number_of_days (+ ?days_per_city ?rest))
                    (hotel ?final_hotel) (IPs_to_visit $?ips)))

                (if (not (eq ?rest 0)) then (bind ?rest 0))
                (bind $?estades (insert$ $?estades (+ (length$ $?estades) 1) ?e)))
        (make-instance (gensym) of Trip (Estades $?estades))
        (retract ?x))

(defrule CAMI::ves-a-presentar
        (declare (salience -10))
        =>
        (focus PRESENTACIO))
;;;=========================================================================
(defrule PRESENTACIO::print
    ?trip <-(object (is-a Trip) (Estades ?e))
    =>
    (progn$ (?i $?e)
        (printout t "Ciutat: " crlf)
        (printout t (send (send ?i get-ciutat) get-NameCity) crlf)
        (printout t "#Dies: " (send ?i get-number_of_days))
        (printout t "Hotel: " (send (send ?i get-hotel) get-NameHotel) crlf)
        (printout t "Punts d'Interés: ")
        (bind ?ips (send ?i get-IPs_to_visit))
        (progn$ (?ip $?ips)
            (printout t " - " (send ?ip get-Name) crlf)))
    (focus MAIN))
