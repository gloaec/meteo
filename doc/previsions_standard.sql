-- ---------------------------------- --
-- Paramètres                         --
-- ---------------------------------- --
SET @rapport_type := 'standard';      -- ou 'plages' ou 'neiges' /!\ PAS IMPLÉMENTÉ
SET @zone         := 'france';        -- ou 'paris'  ou 'monde'
SET @nom          := 'Atlantique';    -- || 'Corse'  || 'Manche' || 'Mediteranee' /!\ PAS IMPLÉMENTÉ
-- ---------------------------------- --
SET @jpicto       := 0;
SET @jtmin        := 0;
SET @jtmax        := 0;

SELECT CONCAT(
  -- ---------------------------------------------------------- --
  -- Transposer les colonnes en regroupant par échéance (carte) --
  -- ---------------------------------------------------------- --

  -- Ville --
  'SELECT `villes`.nom AS `Ville`', 
  
  -- PictoJ1, PictoJ2, ... , PictoJ3 --
  GROUP_CONCAT(
    ', `t_',
    REPLACE(carte_id, '`', '``'),
    '`.temps_sensible AS `PictoJ',
    REPLACE((@jpicto := ifnull(@jpicto, 0) + 1), '`', '``'),
    '`'
  SEPARATOR ''),
  
  -- TempeMinJ1, TempeMinJ2, ... , TempeMinJN --
  GROUP_CONCAT(
    ', `t_',
    REPLACE(carte_id, '`', '``'),
    '`.temperature_min AS `TempeMinJ',
    REPLACE((@jtmin := ifnull(@jtmin, 0) + 1), '`', '``'),
    '`'
  SEPARATOR ''),
  
  -- TempeMaxJ1, TempeMaxJ2, ... , TempeMaxJN --
  GROUP_CONCAT(
    ', `t_',
    REPLACE(carte_id, '`', '``'),
    '`.temperature_max AS `TempeMaxJ',
    REPLACE((@jtmax := ifnull(@jtmax, 0) + 1), '`', '``'),
    '`'
  SEPARATOR ''),
  
  ' FROM `villes` ',
  
  -- concaténation en colonnes --
  GROUP_CONCAT(
    'JOIN `villes` AS `t_',
    REPLACE(carte_id, '`', '``'),
    '` ON `villes`.nom = `t_',
    REPLACE(carte_id, '`', '``'),
    '`.nom AND `t_',
    REPLACE(carte_id, '`', '``'),
    '`.carte_id = ',
    QUOTE(carte_id)
  SEPARATOR ''),
  ' GROUP BY `villes`.nom'
  
) INTO @qry FROM (

  -- ------------------------------------------------------- --
  -- Récupérer la liste des id des cartes du dernier rapport --
  -- ------------------------------------------------------- --  
  
  SELECT DISTINCT `villes`.carte_id
  FROM  `villes` -- , `cartes`, `domaines`, `previsions`, `rapports`
  JOIN `cartes` 
    ON  `cartes`.id = `villes`.carte_id
  JOIN `domaines` 
    ON  `domaines`.id = `cartes`.domaine_id
    AND (`domaines`.zone = (@zone) COLLATE utf8_unicode_ci -- standard
      OR `domaines`.nom = (@nom) COLLATE utf8_unicode_ci -- plages
    )
  JOIN `previsions` 
    ON  `previsions`.id = `domaines`.prevision_id
  JOIN `rapports` 
    ON  `rapports`.id = `previsions`.rapport_id
    AND `previsions`.rapport_id = (
      SELECT `rapports`.id
      FROM `rapports`
      WHERE `rapports`.rapport_type = (@rapport_type) COLLATE utf8_unicode_ci -- type du rapport
      ORDER BY `rapports`.updated_at DESC -- du dernier au premier
      LIMIT 1 -- prendre seulement le dernier
    )
  ORDER BY `villes`.carte_id ASC -- les échéances par ordre croissant pour la numérotation des colonnes
  
) t;

-- ----------------------- --
-- Execution de la requete --
-- ----------------------- -- 

PREPARE stmt FROM @qry;
EXECUTE stmt;
