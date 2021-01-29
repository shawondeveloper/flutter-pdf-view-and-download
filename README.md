# view_pdf_donwload_any_file

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

CREATE TABLE `pdftable` (
  `id` int(11) NOT NULL,
  `pdffile` text NOT NULL,
  `name` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pdftable`
--

INSERT INTO `pdftable` (`id`, `pdffile`, `name`) VALUES
(3, 'invoice-1778.pdf', 'TEST TEST18'),
(4, 'invoice-7649.pdf', 'TEST4 Shawon Update'),
(5, 'invoice-7650.pdf', 'TEST TEST VFS TEST'),
(6, 'invoice-7653.pdf', 'Md TEST'),
(7, 'invoice-7654.pdf', 'TEST Update Today'),
(8, 'invoice-7655.pdf', 'TEST ANOTHER');
