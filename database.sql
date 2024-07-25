CREATE TABLE IF NOT EXISTS `mri_qplaylists` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`name` VARCHAR(50) NOT NULL DEFAULT '0',
	`owner` VARCHAR(255) NOT NULL DEFAULT '',
	PRIMARY KEY (`id`)
)
COLLATE='utf8mb4_general_ci'
;
CREATE TABLE IF NOT EXISTS `mri_qsongs` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`url` VARCHAR(50) NOT NULL DEFAULT '0',
	`name` VARCHAR(150) NOT NULL DEFAULT '0',
	`author` VARCHAR(50) NOT NULL DEFAULT '0',
	`maxDuration` INT NOT NULL DEFAULT 0,
	PRIMARY KEY (`id`),
	UNIQUE INDEX `url` (`url`)
)
COLLATE='utf8mb4_general_ci'
;
CREATE TABLE IF NOT EXISTS `mri_qplaylists_users` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`license` VARCHAR(255) NOT NULL DEFAULT '',
	`playlist` INT NOT NULL DEFAULT 0,
	INDEX `license` (`license`),
	PRIMARY KEY (`id`),
	CONSTRAINT `FK__mri_qplaylists_users` FOREIGN KEY (`playlist`) REFERENCES `mri_qplaylists` (`id`) ON UPDATE CASCADE ON DELETE CASCADE
)
COLLATE='utf8mb4_general_ci'
;
CREATE TABLE IF NOT EXISTS `mri_qplaylist_songs` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`playlist` INT NOT NULL DEFAULT '0',
	`song` INT NOT NULL DEFAULT '0',
	PRIMARY KEY (`id`),
	CONSTRAINT `FK__mri_qplaylists` FOREIGN KEY (`playlist`) REFERENCES `mri_qplaylists` (`id`) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT `FK__mri_qsongs` FOREIGN KEY (`song`) REFERENCES `mri_qsongs` (`id`) ON UPDATE CASCADE ON DELETE CASCADE
)
COLLATE='utf8mb4_general_ci'
;