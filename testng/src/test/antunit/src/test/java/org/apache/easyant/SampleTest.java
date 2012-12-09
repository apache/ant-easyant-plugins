package org.apache.easyant;

import org.testng.annotations.*;
import org.testng.Assert;

public class SampleTest {

    @Test
    public void testTrue() {
       Assert.assertTrue(true);
    }
    @Test
    public void testShouldFail() {
       Assert.assertTrue(false);
    }

}
