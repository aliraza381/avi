package test

import (
   "github.com/gruntwork-io/terratest/modules/terraform"
   test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
   "testing"
   "os"
)

func TestDeployment(t *testing.T) {
   t.Parallel()

   //clientID := os.Getenv("ARM_CLIENT_ID")
   //clientSecret := os.Getenv("ARM_CLIENT_SECRET")
   //subscriptionID := os.Getenv("ARM_SUBSCRIPTION_ID")
   //tenantID := os.Getenv("ARM_TENANT_ID")
   
	//if clientID == "" {
	//	t.Fatalf("Azure Client ID environment variable cannot be empty.")
	//}
   //if clientSecret == "" {
	//	t.Fatalf("Azure Client Secret environment variable cannot be empty.")
	//}
   //if subscriptionID == "" {
	//	t.Fatalf("Azure Subscription environment variable cannot be empty.")
	//}
   //if tenantID == "" {
	//	t.Fatalf("Azure Tenant environment variable cannot be empty.")
	//}

   siteType := os.Getenv("site_type")

   if siteType == "" {
		t.Fatalf("site_type environment variable cannot be empty. single-site or gslb are valid values")
	}

   TerraformDir := "../examples/" + siteType

   // Uncomment these when doing local testing if you need to skip any stages.
   //os.Setenv("SKIP_destroy", "true")

   // Destroy the infrastructure
   test_structure.RunTestStage(t, "destroy", func() {
      //terratestOptions := &terraform.Options{
         // The path to where your Terraform code is located
        // TerraformDir: TerraformDir,
         //Vars: terraVars,
      //}
      terraformOptions := test_structure.LoadTerraformOptions(t, TerraformDir)
      terraform.Destroy(t, terraformOptions)
   })

}