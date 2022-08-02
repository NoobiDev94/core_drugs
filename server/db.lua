vRP.prepare('core_drugs/create_plants',
    [[
        CREATE TABLE IF NOT EXISTS `plants` (
            `id` INT(11) NOT NULL AUTO_INCREMENT,
            `coords` longtext,
            `type` varchar(100) NOT NULL,
            `water` double NOT NULL,
            `food` double NOT NULL,
            `growth` double NOT NULL,
            `rate` double NOT NULL,
            `markid` INT(11) NOT NULL,
            `owner` INT(11) NOT NULL,
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
    ]]
)

vRP.prepare('core_drugs/create_tabletprocess',
    [[
        CREATE TABLE IF NOT EXISTS `processing` (
            `id` INT(11) NOT NULL AUTO_INCREMENT,
            `type` varchar(100) NOT NULL,
            `item` longtext,
            `time` int(11) NOT NULL,
            `coords` longtext,
            `rot` double NOT NULL,
            `markid` INT(11) NOT NULL,
            `owner` INT(11) NOT NULL,
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
    ]]
)

