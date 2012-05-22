Prog : Dynamic Images PHP
=========================

You can pull an image from a database

::

        img src="show_img.php?id=34">

::

        <?php
        # show_img.php
        // Get image (blob) from database
        include("mysql_library.php");
        $id = $_GET['id'];
        $sql = "select IMAGE from parts where ID = '$id'";
        $img = execute_sql($sql);

        //Send Image to the browser
        header("Content-type: image/jpeg");
        echo base64_decode($img);
        exit;
        ?>


You can select an image to display like this

::

        <img src="show_img.php?id=puppy.jpg");


::

        <?php
        # show_img.php
        // Create (send to browser) mime type for a jpeg image
        header("Content-type: image/jpeg");

        // Create an image handle from an actual JPG image
        $im = @imagecreatefromjpg($_GET['id']);

        // Create an image from the handle and send to browser
        imagejpg($im);

        // Destroy the old image (no longer needed)
        imagedestroy($im);

        // Execute an exit to ensure file execution is over 
        exit;
        ?>


You can create dynamic content

::

        <img src="show_time.php">

::

        <? 
        $image = imagecreate($width=750, $height=800);
        $bgcolor = imagecolorallocate ($image, 0, 0, 0);
        $fgcolor = imagecolorallocate ($image, 255, 255, 255);

        // write the time
        $font = imageloadfont ("anonymous.gif");
        imagestring($image, $font, 20, 240, date("r", time()), fgcolor);

        // send image to the browser
        header('Content-type: image/jpeg');
        imagejpeg($image);

        imagedestroy($image);
        exit;
        ?>

