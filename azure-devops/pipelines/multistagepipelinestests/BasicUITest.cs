using FluentAssertions;
using Microsoft.Extensions.Configuration;
using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using System;
using Xunit;

namespace multistagepipelinestests
{
    public class BasicUITest : IDisposable
    {
        private readonly ChromeDriver _driver;
        private readonly IConfigurationRoot _config;

        public BasicUITest()
        {
            _config = new ConfigurationBuilder()
                .AddJsonFile("testsettings.json")
                .Build();

            var options = new ChromeOptions();
            options.AddArgument("headless");
            _driver = new ChromeDriver(".", options);
        }

        [Fact]
        public void GivenBasicWebsiteThenConfirmWelcomeHeaderIsCorrect()
        {
            // Arrange
            _driver.Navigate().GoToUrl(_config["baseSiteUrl"]);

            // Act
            var headingText = _driver.FindElementByTagName("h1").Text;
            TakeScreenShot("welcome");

            // Assert
            headingText.Should().Be("Welcome");
        }

        [Fact]
        public void GivenBasicWebsiteWhenPrivacyMenuIsSelectedThenNavigateToPrivacyPage()
        {
            // Arrange
            _driver.Navigate().GoToUrl(_config["baseSiteUrl"]);

            // Act
            _driver.FindElementByLinkText("Privacy").Click();
            TakeScreenShot("privacy");

            // Assert
            _driver.Url.Should().Be($"{_config["baseSiteUrl"]}Privacy");
        }

        private void TakeScreenShot(string name)
        {
            if (!string.IsNullOrWhiteSpace(name))
            {
                // Take the screenshot
                var image = (_driver as ITakesScreenshot).GetScreenshot();

                // Save the screenshot
                image.SaveAsFile($"{name}.png", ScreenshotImageFormat.Png);
            }
        }

        public void Dispose()
        {
            _driver?.Dispose();
        }
    }
}